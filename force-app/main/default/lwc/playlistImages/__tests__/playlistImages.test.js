import { createElement } from "lwc";
import PlaylistImages from "c/playlistImages";
import { getRecord } from "lightning/uiRecordApi";
import obtenerDatos from "@salesforce/apex/PlaylistImagesController.obtenerDatos";

jest.mock(
  "@salesforce/apex/PlaylistImagesController.obtenerDatos",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

describe("c-playlist-images", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    // Prevent data saved on mocks from leaking between tests
    jest.clearAllMocks();
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  async function flushPromises() {
    return Promise.resolve();
  }

  it("ID the spotify", async () => {
    obtenerDatos.mockResolvedValue("https://www.url.com");
    // Arrange
    const element = createElement("c-playlist-images", {
      is: PlaylistImages
    });
    document.body.appendChild(element);
    const mock = { fields: { SpotifyId__c: { value: "123456" } } };
    getRecord.emit(mock);
    await flushPromises();
    const urlImage = element.shadowRoot.querySelector("img");
    expect(urlImage.src).toBe("https://www.url.com");
  });
});
