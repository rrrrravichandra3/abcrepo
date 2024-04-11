import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import fdResources from '@salesforce/resourceUrl/FrontDeskCustom';
import PROMPT from '@salesforce/label/c.FdEmp_Footer_Feedback_Prompt';
import INSTRUCTIONS from '@salesforce/label/c.FdEmp_Footer_Feedback_Instructions';
import getConfigurationValue from '@salesforce/apex/FdEmp_ConfigurationValue.getConfigurationValue';

const ENTER = 13;
const PLACEHOLDER = '{0}';
const STYLE = "background-image: url('{0}');";
const FEEDBACK_CHANNEL = '#feedback-basecamp';
const FEEDBACK_LINK = `<a role="button" tabindex="0">${FEEDBACK_CHANNEL}</a>`;

const className = 'footer';

/** @slot content */
export default class FdEmpFooter extends NavigationMixin(LightningElement) {
  _clickListener;
  _keyUpListener;

  @api
  footerBladeImage = `${fdResources}/images/footer/blade.png`;

  @api
  footerStyle;

  @api
  feedbackContainerClass = `${className}-feedback__container`;

  get classList() {
    return `${className}${!this.isKnowledgePage ? '' : ` ${className}--knowledge`}`;
  }

  getIsKnowledgePage({ attributes, type }) {
    return type === 'standard__recordPage' && attributes?.objectApiName === 'Knowledge__kav';
  }

  @wire(CurrentPageReference)
  setCurrentPageReference(pageRef) {
    const resourceUrl = this.getFooterResource(pageRef);

    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.footerStyle = STYLE.replace(PLACEHOLDER, resourceUrl);

    this.isKnowledgePage = this.getIsKnowledgePage(pageRef);
  }

  // TODO: move to configuration - the approach here allows for the full URL to be specified
  getFooterResource(pageRef) {
    if (this.getIsKnowledgePage(pageRef)) {
      return `/vforcesite/sfsites/c/resource/FrontDeskCustom/images/footer/bg-mountain2.png`;
    } else if (pageRef?.type === 'standard__search') {
      return `/vforcesite/sfsites/c/resource/FrontDeskCustom/images/footer/bg-valley1.png`;
    }
    return `/vforcesite/sfsites/c/resource/FrontDeskCustom/images/footer/bg-mountain1.png`;
  }

  async handleFeedbackEvent(event) {
    if (event?.type !== 'click' && !(event?.type === 'keyup' && event?.keyCode === ENTER)) {
      return;
    }

    event.preventDefault();
    let url;
    await getConfigurationValue({ configName: 'FeedbackSlackURL' })
      .then((data) => {
        url = data;
      })
      .catch((error) => {
        console.error(
          `Error occurred while getting configuration with config name FeedbackSlackURL. Caused by: ${error}`
        );
      });
    if (url) {
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
          url: url,
        },
      });
    }
  }

  renderedCallback() {
    const container = this.template.querySelector(`.${this.feedbackContainerClass}`);
    if (container) {
      // eslint-disable-next-line @lwc/lwc/no-inner-html
      container.innerHTML = this.getFooterText();
      const link = container.querySelector('a');
      // this variable is used to store the object for the handleFeedbackEvent function.
      // When using add event listener to bind to the the right object, we are
      // using the .bind(this) to bind it to the right object.
      const handleFeed = this.handleFeedbackEvent.bind(this);
      this._clickListener = link.addEventListener('click', handleFeed);
      this._keyUpListener = link.addEventListener('keyup', handleFeed);
    } else {
      console.warn('footer feedback container not found!');
    }
  }

  disconnectedCallback() {
    if (this._clickListener) {
      this._clickListener.remove();
      this._clickListener = null;
    }
    if (this._keyUpListener) {
      this._keyUpListener.remove();
      this._keyUpListener = null;
    }
  }

  getFooterText() {
    if (INSTRUCTIONS?.includes(PLACEHOLDER)) {
      return PROMPT + '<br/>' + INSTRUCTIONS.replace(PLACEHOLDER, FEEDBACK_LINK);
    }
    return PROMPT + '<br/>' + INSTRUCTIONS + ' ' + FEEDBACK_LINK;
  }
}