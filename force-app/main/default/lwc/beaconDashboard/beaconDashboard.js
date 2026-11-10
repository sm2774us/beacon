import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getKpis from '@salesforce/apex/BeaconKpiController.getKpis';
import getQueue from '@salesforce/apex/BeaconKpiController.getQueue';
import getCompare from '@salesforce/apex/BeaconKpiController.getCompare';
import triageAll from '@salesforce/apex/BeaconKpiController.triageAll';
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
    { label: 'Prompt', fieldName: 'promptVersion', type: 'text', initialWidth: 80 },
    { label: 'Agent recommendation', fieldName: 'recommendation', type: 'text', wrapText: true },
    { type: 'button', initialWidth: 110, typeAttributes: { label: { fieldName: 'runLabel' }, name: 'run', variant: 'brand', disabled: { fieldName: 'notRunnable' } } },
    { type: 'button', initialWidth: 100, typeAttributes: { label: 'Approve', name: 'approve', variant: 'success', disabled: { fieldName: 'notPending' } } },
    { type: 'button', initialWidth: 90, typeAttributes: { label: 'Reject', name: 'reject', variant: 'destructive', disabled: { fieldName: 'notPending' } } }
];

const CMP_COLUMNS = [
    { label: 'Event', fieldName: 'id', type: 'text', initialWidth: 85 },
    { label: 'Finding', fieldName: 'title', type: 'text' },
    { label: 'Golden', fieldName: 'expected', type: 'text', initialWidth: 95 },
    { label: 'v1', fieldName: 'v1Text', type: 'text', wrapText: true },
    { label: 'v2', fieldName: 'v2Text', type: 'text', wrapText: true },
    { label: 'Change', fieldName: 'delta', type: 'text', initialWidth: 95 },
    { type: 'button', initialWidth: 90, typeAttributes: { label: 'Detail', name: 'detail', variant: 'neutral' } }
];
const PROMPTS = [{ label: 'v1', value: 'v1' }, { label: 'v2', value: 'v2' }];
const txt = r => `${r.category}${r.pass === true ? ' ✓' : r.pass === false ? ' ✗' : ''} | ${r.score} | ${r.status}`;

export default class BeaconDashboard extends LightningElement {
    columns = COLUMNS;
    cmpColumns = CMP_COLUMNS;
    promptOptions = PROMPTS;
    prompt = 'v2';
    detailId;
    compareResult;
    busy = false;
    error;
    kpiResult;
    queueResult;
    timer;

    @wire(getKpis) wiredKpis(result) { this.kpiResult = result; }
    @wire(getQueue) wiredQueue(result) { this.queueResult = result; }
    @wire(getCompare) wiredCompare(result) { this.compareResult = result; }

    connectedCallback() { this.timer = setInterval(() => this.refresh(), 5000); }
    disconnectedCallback() { clearInterval(this.timer); }

    get kpi() { return this.kpiResult && this.kpiResult.data; }
    get rows() {
        return ((this.queueResult && this.queueResult.data) || []).map(r => ({ ...r, runLabel: (r.status === 'New' ? 'Run ' : 'Re-run ') + this.prompt }));
    }
    get runAllLabel() { return `Run agent on all (${this.prompt})`; }
    get cmp() { return this.compareResult && this.compareResult.data; }
    get summary() { return this.cmp && this.cmp.summary; }
    get cmpRows() {
        return this.cmp ? this.cmp.rows.map(r => ({ id: r.id, title: r.title, expected: r.expected || 'n/a', v1Text: txt(r.v1), v2Text: txt(r.v2),
            delta: r.outcomeChanged ? 'outcome' : (r.categoryChanged ? 'category' : 'same') })) : [];
    }
    get metrics() {
        const s = this.summary;
        if (!s) { return []; }
        const m = (label, a, b, max, fmt) => ({ label, a: fmt(a), b: fmt(b), pa: Math.min(100, (a / max) * 100), pb: Math.min(100, (b / max) * 100) });
        const id = x => x, pc = x => `${x}%`;
        return [
            m('Golden-set accuracy', s.v1.passRate, s.v2.passRate, 100, pc),
            m('Auto-closed (touchless)', s.v1.autoClosed, s.v2.autoClosed, s.total, id),
            m('Sent to "other" bucket', s.v1.otherBucket, s.v2.otherBucket, s.total, id),
            m('Avg confidence', s.v1.avgConfidence, s.v2.avgConfidence, 1, id),
            m('Analyst hours saved', s.v1.hoursSaved, s.v2.hoursSaved, Math.max(s.v1.hoursSaved, s.v2.hoursSaved, 1), id)
        ];
    }
    get headline() {
        const s = this.summary;
        return s ? `${s.categoryChanged} of ${s.total} findings change category and ${s.outcomeChanged} change outcome between v1 and v2 (v1 ${s.v1.passed}/${s.v1.total} vs v2 ${s.v2.passed}/${s.v2.total} on the golden set). v2 was tuned on this same set, so read its score as a regression gate, not real-world accuracy.` : '';
    }
    get detail() { return this.cmp && this.detailId ? this.cmp.rows.find(r => r.id === this.detailId) : undefined; }
    get detailCols() {
        const d = this.detail;
        if (!d) { return []; }
        const col = (v, r) => ({ key: v, title: `Prompt ${v}`, status: r.status, ok: r.pass, rows: [
            ['Category', r.category], ['Score', `${r.score} (${r.band})`], ['Confidence', r.confidence], ['Guardrail', (r.guardrails || []).join(', ') || 'none'],
            ['Owner', r.owner], ['Latency (simulated)', `${r.latencyMs} ms`], ['Analyst-min saved', r.minutesSaved] ].map(x => ({ k: x[0], v: x[1] })),
            steps: (r.steps || []).filter(s => s.tool === 'classify_llm' || s.tool === 'policy_guardrail').map(s => ({ k: s.tool, v: s.output })) });
        return [col('v1', d.v1), col('v2', d.v2)];
    }
    get detailTitle() { const d = this.detail; return d ? `${d.id}: ${d.title} (golden: ${d.expected || 'n/a'})` : ''; }
    handlePrompt(e) { this.prompt = e.detail.value; }
    handleCmpAction(e) { this.detailId = e.detail.row.id; }
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
    handleRun() { return this.run(() => triageAll({ ver: this.prompt, includeTriaged: true })); }
    handleReset() { return this.run(() => resetDemo()); }
    handleRowAction(event) {
        const name = event.detail.action.name;
        const id = event.detail.row.id;
        if (name === 'run') { return this.run(() => triageOne({ ref: id, ver: this.prompt })); }
        return this.run(() => decide({ ref: id, decision: name }));
    }
}
