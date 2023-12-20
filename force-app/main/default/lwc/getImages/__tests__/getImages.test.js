import { createElement } from "lwc";
import getImages from "c/getImages";
import { getRecord } from "lightning/uiRecordApi";
import findUrl from "@salesforce/apex/ImagesController.findUrl";

jest.mock(
  "@salesforce/apex/ImagesController.findUrl",
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
    const urls = [
      "https://www.url.com",
      "https://www.url2.com",
      "https://www.url3.com"
    ];
    findUrl.mockResolvedValue(urls);

    const element = createElement("c-get-images", {
      is: getImages
    });

    document.body.appendChild(element);
    const mock = { fields: { SpotifyId__c: { value: "123456" } } };
    // Act
    getRecord.emit(mock);
    await flushPromises();
    // Assert
    const urlImages = element.shadowRoot.querySelectorAll(
      "lightning-carousel-image"
    );
    //expect(urlImage.src).toBe("https://www.url.com");
    expect(urlImages.length).toBe(urls.length);
    // Verificar que cada imagen tenga la URL esperada
    urlImages.forEach((urlImage, index) => {
      expect(urlImage.src).toBe(urls[index]);
    });
  });
});
