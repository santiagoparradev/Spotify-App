import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import obtenerDatos from "@salesforce/apex/PlaylistImagesController.obtenerDatos";
import SPOTIFY_ID_FIELD from "@salesforce/schema/Playlist__c.SpotifyId__c";

export default class PlaylistImages extends LightningElement {
  @api recordId;
  messageUrl;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [SPOTIFY_ID_FIELD]
  })
  wireGetRecord({ data }) {
    if (data) {
      const spotifyPlaylistId = getFieldValue(data, SPOTIFY_ID_FIELD);
      obtenerDatos({ spotifyPlaylistId })
        .then((result) => {
          this.messageUrl = result;
        })
        .catch((error) => {
          this.error = error;
        });
    }
  }
}
