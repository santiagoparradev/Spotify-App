import { createElement } from "lwc";
import trackPreview from "c/trackPreview";
import { getRecord } from "lightning/uiRecordApi";
import findTrackPreviewUrl from "@salesforce/apex/trackPreviewController.findTrackPreviewUrl";

jest.mock(
  "@salesforce/apex/trackPreviewController.findTrackPreviewUrl",
  () => ({
    default: jest.fn()
  }),
  { virtual: true }
);

describe("c-getImages", () => {
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

  it("the url expect is equal to string in tobe", async () => {
    // Arrange
    const urls = ["https://www.url.com/"];
    findTrackPreviewUrl.mockResolvedValue(urls);

    const element = createElement("c-track-preview", {
      is: trackPreview
    });

    document.body.appendChild(element);
    const mock = { fields: { SpotifyId__c: { value: "123456" } } };
    // Act
    getRecord.emit(mock);
    await flushPromises();
    // Assert
    const urlTrackPreview = element.shadowRoot.querySelectorAll("audio");

    expect(urlTrackPreview.length).toBe(urls.length);
  });
});
