import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import POPULARITY_FIELD from "@salesforce/schema/Track__c.Popularity__c";

export default class Popularity extends LightningElement {
  @api recordId;
  message;
  color = null;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [POPULARITY_FIELD],
  })
  trackRecord({data, error}) {
    
    if (data) {
      const popularity = getFieldValue(data, POPULARITY_FIELD);
      if (popularity <= 30) {
        document.documentElement.style.setProperty('--titleColor', '#d62023');
        this.message = "THIS SONG IS BAD ACCORDING TO MOST PEOPLE"; 
      } else if (popularity <= 50) {
        document.documentElement.style.setProperty('--titleColor', '#d1d62d');
        this.message = "NOT THE BEST SONG";
      } else if (popularity <= 70) {
        document.documentElement.style.setProperty('--titleColor', '#72b533');
        this.message = "GREAT SONG";
      } else {
        document.documentElement.style.setProperty('--titleColor', '#40f702');
        this.message = "THIS SONG IS FIRE";
      } 
    } else if (error) {
        message = "error";
    }
  }
}