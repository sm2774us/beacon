import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getKpis from '@salesforce/apex/BeaconKpiController.getKpis';
import getQueue from '@salesforce/apex/BeaconKpiController.getQueue';
import triageNew from '@salesforce/apex/BeaconKpiController.triageNew';

const COLUMNS = [
    { label: 'Finding', fieldName: 'Name', type: 'text', initialWidth: 90 },
    { label: 'Title', fieldName: 'Title__c', type: 'text' },
    { label: 'Severity', fieldName: 'Severity__c', type: 'text', initialWidth: 90 },
    { label: 'Category', fieldName: 'Category__c', type: 'text', initialWidth: 100 },
    { label: 'Risk', fieldName: 'Risk_Score__c', type: 'number', initialWidth: 70 },
    { label: 'Status', fieldName: 'Status__c', type: 'text', initialWidth: 140 },
    { label: 'Agent recommendation', fieldName: 'Agent_Recommendation__c', type: 'text', wrapText: true }
];

export default class BeaconDashboard extends LightningElement {
    columns = COLUMNS;
    busy = false;
    error;
    kpiResult;
    queueResult;

    @wire(getKpis) wiredKpis(result) { this.kpiResult = result; }
    @wire(getQueue) wiredQueue(result) { this.queueResult = result; }

    get kpi() { return this.kpiResult && this.kpiResult.data; }
    get rows() { return (this.queueResult && this.queueResult.data) || []; }
    get tiles() {
        const k = this.kpi || {};
        return [
            { label: 'Findings triaged', value: `${k.triaged || 0} / ${k.total || 0}` },
            { label: 'Auto-closed (touchless)', value: k.autoClosed || 0 },
            { label: 'Awaiting human approval', value: k.pending || 0 },
            { label: 'Blocked by guardrail', value: k.blocked || 0 },
            { label: 'Analyst hours saved', value: (k.hoursSaved || 0).toFixed(1) },
            { label: 'Value @ $85/h', value: `$${Math.round((k.hoursSaved || 0) * 85)}` },
            { label: 'Avg latency (ms)', value: Math.round(k.avgLatencyMs || 0) },
            { label: 'Guardrails fired', value: k.guardrails || 0 }
        ];
    }

    async handleDone() {
        await Promise.all([refreshApex(this.kpiResult), refreshApex(this.queueResult)]);
    }

    async handleRun() {
        this.busy = true;
        this.error = undefined;
        try {
            await triageNew();
            await Promise.all([refreshApex(this.kpiResult), refreshApex(this.queueResult)]);
        } catch (e) {
            this.error = (e.body && e.body.message) || e.message;
        } finally {
            this.busy = false;
        }
    }
}
