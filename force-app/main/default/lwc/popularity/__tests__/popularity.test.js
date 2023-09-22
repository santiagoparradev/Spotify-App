import { createElement } from "lwc";
import Popularity from "c/popularity";
import { getRecord } from "lightning/uiRecordApi";
describe("c-popularity", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });
  it("popularity is minor to 30", () => {
    // Arrange
    const element = createElement("c-popularity", {
      is: Popularity
    });
    // Act
    document.body.appendChild(element);

    //Emit mock record into the wired field
    const mock = { fields: { Popularity__c: { value: 15 } } };
    getRecord.emit(mock);

    //Resolve a promise
    return Promise.resolve().then(() => {
      const content = element.shadowRoot.querySelector("p");

      // Assert
      // const div = element.shadowRoot.querySelector('div');
      expect(content.textContent).toBe(
        "this song is bad according to most people"
      );
    });
  });
  it("popularity is high", () => {
    // Arrange
    const element = createElement("c-popularity", {
      is: Popularity
    });
    // Act
    document.body.appendChild(element);

    //Emit mock record into the wired field
    const mock = { fields: { Popularity__c: { value: 101 } } };
    getRecord.emit(mock);

    //Resolve a promise
    return Promise.resolve().then(() => {
      const content = element.shadowRoot.querySelector("p");

      // Assert
      // const div = element.shadowRoot.querySelector('div');
      expect(content.textContent).toBe("this song is fire");
    });
  });
});
