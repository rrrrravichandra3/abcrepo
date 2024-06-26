import { LightningElement } from 'lwc';

export default class SfContextNav extends LightningElement {
    contextNavItems = { "newWindowAlt": "_blank", 
    "variation": "static", 
    "isLogoEnabled": false, 
    "propertyTitle": 
        { "label": "Careers", "url": "/careers" }, 
    "propertyLogo": { "alt": "Careers" }, 
    "menuGroup": 
        { "menuItems": 
            [{ 
                 "visibility": "unauthenticated" }, 
                { "title": "Life at Salesforce", 
                    "submenu": [{ "menuItems": 
                        [{ "link": 
                            { "label": "How We Hire", "url": "how-we-hire" } 
                        },
                        { "link": 
                            { "label": "Interview Advice", "url": "interview-advice" }
                        }, 
                        { "link": 
                            { "label": "Alumni", "url": "alumni" }
                        }], "hasSeparator": true }] 
                },
                { "title": "Our Locations", 
                    "submenu": [{ "menuItems": 
                        [{ "link": 
                            { "label": "North America", "url": "north-america" } 
                        },
                        { "link": 
                            { "label": "Europe, Middle East, and Africa", "url": "europe-middle-east-africa" }
                        }, 
                        { "link": 
                            { "label": "Asia Pacific", "url": "asia-pacific" }
                        },
                        { "link": 
                            { "label": "Latin America", "url": "latin-america" }
                        }], "hasSeparator": true }] 
                },
                { "title": "Our Teams", 
                    "submenu": [{ "menuItems": 
                        [{ "link": 
                            { "label": "Sales", "url": "sales" } 
                        },
                        { "link": 
                            { "label": "Technology & Product", "url": "tmp" }
                        }, 
                        { "link": 
                            { "label": "Customer Success", "url": "customer-success" }
                        }, 
                        { "link": 
                            { "label": "Marketing & Comunications", "url": "marketing-comms" }
                        }, 
                        { "link": 
                            { "label": "Employee Success", "url": "employee-success" }
                        }, 
                        { "link": 
                            { "label": "Real Estate & Workspace Services", "url": "rews" }
                        }, 
                        { "link": 
                            { "label": "Finance", "url": "finance" }
                        }, 
                        { "link": 
                            { "label": "Legal & Corporate Affairs", "url": "legal-corp-affairs" }
                        }, 
                        { "link": 
                            { "label": "Salesforce Research", "url": "sf-research" }
                        }, 
                        { "link": 
                            { "label": "Business Technology", "url": "bt" }
                        }], "hasSeparator": true }] 
                },
                { "title": "University", 
                    "submenu": [{ "menuItems": 
                        [{ "link": 
                            { "label": "Futureforce Intern Program", "url": "futureforce" } 
                        },
                        { "link": 
                            { "label": "Associate Product Manager", "url": "associate-pm" }
                        }, 
                        { "link": 
                            { "label": "Advanced Degrees (MBA)", "url": "adv-degrees" }
                        }], "hasSeparator": true }] 
                },
                { "title": "Future Pathways", 
                    "submenu": [{ "menuItems": 
                        [{ "link": 
                            { "label": "Internships", "url": "internships" } 
                        },
                        { "link": 
                            { "label": "Apprenticeships", "url": "Apprenticeships" }
                        }, 
                        { "link": 
                            { "label": "Salesforce India Return to Work Program", "url": "india-rtw" }
                        }], "hasSeparator": true }] 
                },
                {"link":{"label":"Salesforce Stories","url":"salesforce-stories"}} 
            ]}, 
            "utilityNavigation": { 
                "ctasecondary": { 
                    "visibility": "unauthenticated", 
                    "cta": { "label": "Search Jobs", "ariaLabel": "Search Jobs", "url": "/job-search", "variant": "primary", "target": "_self"},
                    "inMobileHeader": true },
                "ctamain": { 
                    "visibility": "unauthenticated", 
                    "cta": { "label": "Saved Jobs", "ariaLabel": "Saved Jobs", "url": "/saved-jobs", "variant": "secondary", "target": "_self" },
                    "inMobileHeader": true }
            }
        };

        connectedCallback() {
            this.dispatchAddContextNav();
        }
    
        renderedCallback() {
            this.dispatchAddContextNav();
        }

        dispatchAddContextNav() {
            const evtCont = new CustomEvent('add_context_nav', {
                detail: {
                    data: this.contextNavItems
                },
                bubbles: true,
                composed: false
            });
            this.dispatchEvent(evtCont);
        }
}