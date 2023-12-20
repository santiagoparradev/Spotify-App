import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import findUrl from "@salesforce/apex/ImagesController.findUrl";
import SPOTIFY_ID_FIELD_PLAYLIST from "@salesforce/schema/Playlist__c.SpotifyId__c";
import SPOTIFY_ID_FIELD_ALBUM from "@salesforce/schema/Album__c.SpotifyId__c";
import SPOTIFY_ID_FIELD_ARTIST from "@salesforce/schema/Artist__c.SpotifyId__c";
import ALBUM_OBJECT from "@salesforce/schema/Album__c";
import PLAYLIST_OBJECT from "@salesforce/schema/Playlist__c";
import ARTIST_OBJECT from "@salesforce/schema/Artist__c";

const ALL_FIELDS = [
  SPOTIFY_ID_FIELD_PLAYLIST,
  SPOTIFY_ID_FIELD_ALBUM,
  SPOTIFY_ID_FIELD_ARTIST
];
const ENDPOINT_BY_OBJECT = {
  [ALBUM_OBJECT.objectApiName]: "albums",
  [PLAYLIST_OBJECT.objectApiName]: "playlists",
  [ARTIST_OBJECT.objectApiName]: "artists"
};

export default class GetImages extends LightningElement {
  @api recordId;
  @api objectApiName;
  imageUrl;
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
      const objectApiNameSpotifyId = getFieldValue(data, this.fields);
      const endPoint = `https://api.spotify.com/v1/${
        ENDPOINT_BY_OBJECT[this.objectApiName]
      }/`;
      findUrl({ objectApiNameSpotifyId, endPoint })
        .then((result) => {
          this.imageUrl = result;
        })
        .catch((error) => {
          this.error = error.body.message;
        });
    } else if (errors) {
      this.error = errors;
    }
  }
}
