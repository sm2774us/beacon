import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getKpis from '@salesforce/apex/BeaconKpiController.getKpis';
import getQueue from '@salesforce/apex/BeaconKpiController.getQueue';
import triageNew from '@salesforce/apex/BeaconKpiController.triageNew';
import triageOne from '@salesforce/apex/BeaconKpiController.triageOne';
import decide from '@salesforce/apex/BeaconKpiController.decide';
import resetDemo from '@salesforce/apex/BeaconKpiController.resetDemo';

const COLUMNS = [
    { label: 'Event', fieldName: 'id', type: 'text', initialWidth: 85 },
    { label: 'Title', fieldName: 'title', type: 'text' },
    { label: 'Severity', fieldName: 'severity', type: 'text', initialWidth: 90 },
    { label: 'Category', fieldName: 'category', type: 'text', initialWidth: 100 },
    { label: 'Risk', fieldName: 'score', type: 'number', initialWidth: 70 },
    { label: 'Status', fieldName: 'status', type: 'text', initialWidth: 160 },
    { label: 'Agent recommendation', fieldName: 'recommendation', type: 'text', wrapText: true },
    { type: 'button', initialWidth: 80, typeAttributes: { label: 'Run', name: 'run', variant: 'brand', disabled: { fieldName: 'notRunnable' } } },
    { type: 'button', initialWidth: 100, typeAttributes: { label: 'Approve', name: 'approve', variant: 'success', disabled: { fieldName: 'notPending' } } },
    { type: 'button', initialWidth: 90, typeAttributes: { label: 'Reject', name: 'reject', variant: 'destructive', disabled: { fieldName: 'notPending' } } }
];

export default class BeaconDashboard extends LightningElement {
    columns = COLUMNS;
    busy = false;
    error;
    kpiResult;
    queueResult;
    timer;

    @wire(getKpis) wiredKpis(result) { this.kpiResult = result; }
    @wire(getQueue) wiredQueue(result) { this.queueResult = result; }

    connectedCallback() { this.timer = setInterval(() => this.refresh(), 5000); }
    disconnectedCallback() { clearInterval(this.timer); }

    get kpi() { return this.kpiResult && this.kpiResult.data; }
    get rows() { return (this.queueResult && this.queueResult.data) || []; }
    get tiles() {
        const k = this.kpi || {};
        const n = v => (v === undefined || v === null ? 0 : v);
        return [
            { label: 'findings triaged', value: `${n(k.processed)}/${n(k.total)}` },
            { label: 'auto-closed (touchless)', value: n(k.autoClosed) },
            { label: 'awaiting human approval', value: n(k.pending) },
            { label: 'blocked by guardrail', value: n(k.blocked) },
            { label: 'analyst time saved', value: `${n(k.hoursSaved)} h` },
            { label: 'value @ $85/h', value: `$${n(k.dollarsSaved)}` },
            { label: 'avg agent latency', value: `${n(k.avgLatencyMs)} ms` },
            { label: 'human override rate', value: `${n(k.overrideRate)}%` }
        ];
    }

    refresh() {
        if (this.busy || !this.kpiResult || !this.queueResult) { return; }
        Promise.all([refreshApex(this.kpiResult), refreshApex(this.queueResult)]).catch(() => {});
    }

    async run(fn) {
        this.busy = true;
        this.error = undefined;
        try {
            await fn();
            await Promise.all([refreshApex(this.kpiResult), refreshApex(this.queueResult)]);
        } catch (e) {
            this.error = (e.body && e.body.message) || e.message;
        } finally {
            this.busy = false;
        }
    }

    handleDone() { this.refresh(); }
    handleRun() { return this.run(() => triageNew()); }
    handleReset() { return this.run(() => resetDemo()); }
    handleRowAction(event) {
        const name = event.detail.action.name;
        const id = event.detail.row.id;
        if (name === 'run') { return this.run(() => triageOne({ ref: id })); }
        return this.run(() => decide({ ref: id, decision: name }));
    }
}
