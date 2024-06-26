import {LightningElement, api} from 'lwc';
import {loadScript, loadStyle} from "lightning/platformResourceLoader";
import Swiper_JS from '@salesforce/resourceUrl/Swiper_JS';
import { NavigationMixin } from 'lightning/navigation';
import Swiper_CSS from '@salesforce/resourceUrl/Swiper_CSS';

export default class PbCoreValuesCard extends NavigationMixin(LightningElement) {
    swiperInitialized = false;
    swiper
    @api header;
    @api subheader;
    @api value1
    @api value2
    @api value3
    @api value4
    @api value5
    @api bushesImageId
    @api value1header
    @api value1text
    @api value2header
    @api value2text
    @api value3header
    @api value3text
    @api value4header
    @api value4text
    @api value5header
    @api value5text
    
    nextButton = document.querySelector('.swiper-button-next');
    baseUrl = 'sfsites/c/cms/delivery/media/';

    __bushesUrl;
    @api
    get bushesUrl() {
        return this.baseUrl + this.bushesImageId;
    }
    set bushesUrl(value) {
        this.__bushesUrl = value;
    }

    __Value1Url;
    @api
    get Value1Url() {
        return this.baseUrl + this.value1;
    }
    set Value1Url(value) {
        this.__Value1Url = value;
    }
    __Value2Url;
    @api
    get Value2Url() {
        return this.baseUrl + this.value2;
    }
    set Value2Url(value) {
        this.__Value2Url = value;
    }

    __Value3Url;
    @api
    get Value3Url() {
        return this.baseUrl + this.value3;
    }
    set Value3Url(value) {
        this.__Value3Url = value;
    }

    __Value4Url;
    @api
    get Value4Url() {
        return this.baseUrl + this.value4;
    }
    set Value4Url(value) {
        this.__Value4Url = value;
    }

    __Value5Url;
    @api
    get Value5Url() {
        return this.baseUrl + this.value5;
    }
    set Value5Url(value) {
        this.__Value5Url = value;
    }
    renderedCallback() {

        if (this.swiperInitialized) {
            return;
        }
        this.swiperInitialized = true;
        Promise.all([
                loadScript(this, Swiper_JS),
                loadStyle(this, Swiper_CSS)
            ]).then(() => {
                this.initializeSwiper();
            })
            .catch(error => {
                console.error('Failed to load Swiper:', error);
            });
        }
    
    handleButtonClick(event) {
        const target = event.target;

        target.classList.add('show-outline');

        setTimeout(() => {
            target.classList.remove('show-outline');
        }, 500);
    }
    
    handleLinkClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://trust.salesforce.com/?_ga=2.190864234.1793531575.1694805634-714980719.1694526233'
            }
        });
    }

    initializeSwiper() {
        console.log('Inside swiper');
        const swiperContainer = this.template.querySelector('.mySwiper');
        const nextElContainer = this.template.querySelector('.swiper-button-next');
        const prevElContainer = this.template.querySelector('.swiper-button-prev')

        this.swiper = new Swiper(swiperContainer, {
            spaceBetween: 20,
            slidesPerView: 1,

            pagination: {
                el: this.template.querySelector('.swiper-pagination'),
                clickable: true
            },
            navigation: {
                nextEl: nextElContainer,
                prevEl: prevElContainer,
            },

            grabCursor: true,
            breakpoints: {
                576: {
                    slidesPerView: 1,
                    spaceBetween: 15,
                },
                768: {
                    slidesPerView: 1,
                    spaceBetween: 15,
                },

                1072: {
                    slidesPerView: 1,
                    spaceBetween: 20,
                },
                1100: {
                    slidesPerView: 2,
                    spaceBetween: 15,
                }
            }

        });


    }
}