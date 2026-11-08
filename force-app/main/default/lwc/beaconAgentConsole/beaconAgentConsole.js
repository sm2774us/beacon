import { LightningElement } from 'lwc';
import ask from '@salesforce/apex/BeaconAgentController.ask';

export default class BeaconAgentConsole extends LightningElement {
    draft = '';
    busy = false;
    seq = 0;
    quick = ['triage E-1002', 'triage E-1010', 'approve E-1002', 'triage all new', 'status'];
    messages = [{ id: 0, who: 'Agent', text: 'Hi, I triage security findings. Try a quick prompt below.', steps: [] }];

    handleChange(e) { this.draft = e.target.value; }
    handleKey(e) { if (e.key === 'Enter') { this.handleSend(); } }
    handleQuick(e) { this.draft = e.target.dataset.q; this.handleSend(); }

    async handleSend() {
        const text = (this.draft || '').trim();
        if (!text || this.busy) { return; }
        this.busy = true;
        this.push('You', text, []);
        this.draft = '';
        try {
            const r = await ask({ message: text });
            this.push('Agent', r.text, r.steps || []);
            this.dispatchEvent(new CustomEvent('agentdone'));
        } catch (e) {
            this.push('Agent', 'Error: ' + ((e.body && e.body.message) || e.message), []);
        } finally {
            this.busy = false;
        }
    }
    push(who, text, steps) {
        this.seq += 1;
        this.messages = [...this.messages, { id: this.seq, who, text, steps }];
    }
}
