import { createElement } from "lwc";
import Popularity from "c/popularity";
import { getRecord } from "lightning/uiRecordApi";
describe("c-popularity", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });
  it("popularity is minor to 30", () => {
    const element = createElement("c-popularity", {
      is: Popularity
    });

    document.body.appendChild(element);

    const mock = { fields: { Popularity__c: { value: 15 } } };
    getRecord.emit(mock);

    return Promise.resolve().then(() => {
      const content = element.shadowRoot.querySelector("p");

      expect(content.textContent).toBe(
        "this song is bad according to most people"
      );
    });
  });
  it("popularity is high", () => {
    const element = createElement("c-popularity", {
      is: Popularity
    });

    document.body.appendChild(element);

    const mock = { fields: { Popularity__c: { value: 101 } } };
    getRecord.emit(mock);

    return Promise.resolve().then(() => {
      const content = element.shadowRoot.querySelector("p");

      expect(content.textContent).toBe("this song is fire");
    });
  });
});
