import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import POPULARITY_FIELD from "@salesforce/schema/Track__c.Popularity__c";

export default class Popularity extends LightningElement {
  @api recordId;
  message;
  @wire(getRecord, { recordId: "$recordId", fields: [POPULARITY_FIELD] })
  trackRecord({ data }) {
    if (data) {
      const popularity = getFieldValue(data, POPULARITY_FIELD);
      let color = null;
      let textColor = "#FFFFFF";

      if (popularity == null) {
        this.message = null;
      } else if (popularity <= 30) {
        color = "#004700";
        this.message = "this song is bad according to most people";
      } else if (popularity <= 50) {
        color = "#007500";
        this.message = "not the best song";
      } else if (popularity <= 70) {
        color = "#00A300";
        this.message = "great song";
      } else {
        this.message = "this song is fire";
        color = "#00D100";
        textColor = "#191414";
      }
      document.documentElement.style.setProperty("--bannerColor", color);
      document.documentElement.style.setProperty("--textColor", textColor);
    }
  }
}
