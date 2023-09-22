import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import POPULARITY_FIELD from "@salesforce/schema/Track__c.Popularity__c";

export default class Popularity extends LightningElement {
  @api recordId;
  message;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [POPULARITY_FIELD]
  })
  trackRecord({ data }) {
    if (data) {
      const popularity = getFieldValue(data, POPULARITY_FIELD);
      let color = "#40f702";
      if (popularity <= 30) {
        color = "#d62023";
        this.message = "this song is bad according to most people";
      } else if (popularity <= 50) {
        color = "#d1d62d";
        this.message = "not the best song";
      } else if (popularity <= 70) {
        color = "#72b533";
        this.message = "great song";
      } else {
        this.message = "this song is fire";
      }
      document.documentElement.style.setProperty("--titleColor", color);
    }
  }
}
