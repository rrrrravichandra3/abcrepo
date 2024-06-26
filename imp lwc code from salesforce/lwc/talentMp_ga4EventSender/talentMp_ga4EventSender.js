import { LightningElement, api, track } from "lwc";

export default class TalentMp_ga4EventSender extends LightningElement {
  renderedCallback() {
    console.log("rendered callback");
  }

  triggerGA() {
    window.dispatchEvent(
      new CustomEvent("GALocalEvent", {
        detail: {
          eventName: "job_recommendation",
          eventParameters: {
            total_recommendation: 232,
            recommendation_generatedby: "Ashutosh Belwal lwc"
          }
        }
      })
    );
  }
}