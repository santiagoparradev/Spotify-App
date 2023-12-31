import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import findTrackPreviewUrl from "@salesforce/apex/trackPreviewController.findTrackPreviewUrl";
import SPOTIFY_ID_FIELD_TRACK from "@salesforce/schema/Track__c.SpotifyId__c";

const ALL_FIELDS = [SPOTIFY_ID_FIELD_TRACK];

export default class trackPreview extends LightningElement {
  @api recordId;
  @api objectApiName;
  trackPreviewUrl;
  error;

  get fields() {
    let spotifyId = ALL_FIELDS.find(
      (apiName) => apiName.objectApiName === this.objectApiName
    )?.fieldApiName;
    return this.objectApiName + "." + spotifyId;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$fields"
  })
  wireGetRecord({ data, errors }) {
    if (data) {
      const recordSpotifyId = getFieldValue(data, this.fields);
      findTrackPreviewUrl({ recordSpotifyId })
        .then((result) => {
          this.trackPreviewUrl = result;
        })
        .catch((error) => {
          this.error = error.body.message;
        });
    } else if (errors) {
      this.error = errors;
    }
  }
}
