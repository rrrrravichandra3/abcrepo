import {
    LightningElement,
    api
} from 'lwc';
import {
    loadScript,
    loadStyle
} from "lightning/platformResourceLoader";
import Swiper_JS from '@salesforce/resourceUrl/Swiper_JS';
import Swiper_CSS from '@salesforce/resourceUrl/Swiper_CSS';

export default class PbHelpfulResources extends LightningElement {
    swiperInitialized = false;
    swiper
    @api header;
    @api subheader;
    @api value1
    @api value2
    @api value3
    @api value4
    @api value5
    @api value6
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
    @api buttonTitle;
    @api buttonTitle2;
    @api buttonTitle3;
    @api buttonTitle4;
    @api buttonLink;
    @api buttonLink2;
    @api buttonLink3;
    @api buttonLink4;

    baseUrl = 'sfsites/c/cms/delivery/media/';

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

    __Value6Url;
    @api
    get Value6Url() {
        return this.baseUrl + this.value6;
    }
    set Value6Url(value) {
        this.__Value6Url = value;
    }

    renderedCallback() {
        if (!this.swiperInitialized) {
            this.swiperInitialized = true;
            Promise.all([
                    loadScript(this, Swiper_JS),
                    loadStyle(this, Swiper_CSS)
                ]).then(() => {
                    this.initializeSwiper();
                })
                .catch(error => {
                  
                });
        }

    }


    initializeSwiper() {
        console.log('Inside swiper');
        const swiperContainer = this.template.querySelector('.mySwiper');
        const nextElContainer = this.template.querySelector('.swiper-button-next');
        const prevElContainer = this.template.querySelector('.swiper-button-prev');

        prevElContainer.addEventListener('click', () => {
            const lastSlide = this.swiper.slides[3];
            lastSlide.classList.add('less-dense');
        });

        nextElContainer.addEventListener('click', () => {
            const lastSlide = this.swiper.slides[3];
            lastSlide.classList.remove('less-dense');
        });

        this.swiper = new Swiper(swiperContainer, {
            slidesPerView: 1,
            spaceBetween: 1,
            pagination: {
                el: this.template.querySelector('.swiper-pagination'),
                clickable: true,
                type: "bullets"
            },
            navigation: {
                nextEl: nextElContainer,
                prevEl: prevElContainer,
            },

            grabCursor: true,

            breakpoints: {
                576: {
                    slidesPerView: 1,
                    spaceBetween: 1,

                },
                768: {
                    slidesPerView: 1,
                    spaceBetween: 1,

                },
                1100: {
                    slidesPerView: 3,
                    spaceBetween: 50,
                }
            },

            on: {
                afterInit: function () {
                    const slides = swiperContainer.querySelectorAll('.swiper-slide');
                    slides[slides.length - 1].classList.add('less-dense');
                },
            },

        });



    }
}