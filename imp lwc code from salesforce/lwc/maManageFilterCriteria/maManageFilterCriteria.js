import { LightningElement,track,wire,api } from 'lwc'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getFieldsSchema from '@salesforce/apex/MA_ManageFilterCriteria.getFieldsSchema'
import updateFilterCriteriaJSON from '@salesforce/apex/MA_ManageFilterCriteria.updateFilterCriteriaJSON'
import getRecordDetails from '@salesforce/apex/MA_ManageFilterCriteria.getRecordDetails'
import { updateRecord } from 'lightning/uiRecordApi'
import { CloseActionScreenEvent } from 'lightning/actions'
import { reduceErrors } from 'c/maErrorHandlingUtility'
import MA_Blank_Condition_Error from '@salesforce/label/c.MA_Blank_Condition_Error'
import MA_Invalid_Characters_Error from '@salesforce/label/c.MA_Invalid_Characters_Error'
import MA_Additional_Character_Error from '@salesforce/label/c.MA_Additional_Character_Error'
import MA_Filter_Criteria_Formula_Label from '@salesforce/label/c.MA_Filter_Criteria_Formula_Label'
import MA_AC_Formula_Label from '@salesforce/label/c.MA_AC_Formula_Label'
import MA_AComp_Formula_Label from '@salesforce/label/c.MA_AComp_Formula_Label'
import MA_Acq_Prov_Formula_Label from '@salesforce/label/c.MA_Acq_Prov_Formula_Label'
import MA_Acq_Comp_Filter_Criteria from '@salesforce/label/c.MA_Acq_Comp_Filter_Criteria'
import MA_Acq_Con_Filter_Criteria_Label from '@salesforce/label/c.MA_Acq_Con_Filter_Criteria_Label'
import MA_Acq_Prov_Filter_Criteria_Label from '@salesforce/label/c.MA_Acq_Prov_Filter_Criteria_Label'
import MA_Filter_Table_Label_Heading from '@salesforce/label/c.MA_Filter_Table_Label_Heading'
import MA_Filter_Table_Operator_Heading from '@salesforce/label/c.MA_Filter_Table_Operator_Heading'
import MA_Filter_Table_Value_Heading from '@salesforce/label/c.MA_Filter_Table_Value_Heading'
import MA_Filter_Table_Action_Heading from '@salesforce/label/c.MA_Filter_Table_Action_Heading'
import MA_Update_Filter_Criteria_Heading from '@salesforce/label/c.MA_Update_Filter_Criteria_Heading'
import MA_Create_Filter_Criteria_Heading from '@salesforce/label/c.MA_Create_Filter_Criteria_Heading'
import MA_Filter_Table_SRNO_Heading from '@salesforce/label/c.MA_Filter_Table_SRNO_Heading'
import MA_Update_Criteria_Button_Label from '@salesforce/label/c.MA_Update_Criteria_Button_Label'
import MA_Filter_Cancel_Button_Label from '@salesforce/label/c.MA_Filter_Cancel_Button_Label'


export default class MaManageFilterCriteria extends LightningElement {
    @api recordId
   
    @track objectFields
    @track operatorOptions
    @track isPickListFieldOptions
    @track fieldName= ''
    @track existingCriterias = []
    @track contactCriteria = []
    @track provisioningCriteria =[]
    @track compensastionCriteria = []

    label = {
        MA_Filter_Criteria_Formula_Label,
        MA_AC_Formula_Label,
        MA_AComp_Formula_Label,
        MA_Acq_Prov_Formula_Label,
        MA_Acq_Comp_Filter_Criteria,
        MA_Acq_Con_Filter_Criteria_Label,
        MA_Acq_Prov_Filter_Criteria_Label,
        MA_Filter_Table_Label_Heading,
        MA_Filter_Table_Operator_Heading,
        MA_Filter_Table_Value_Heading,
        MA_Filter_Table_Action_Heading,
        MA_Update_Filter_Criteria_Heading,
        MA_Create_Filter_Criteria_Heading,
        MA_Filter_Table_SRNO_Heading,
        MA_Update_Criteria_Button_Label,
        MA_Filter_Cancel_Button_Label
    }

    existingCriteriasTemp = []
    contactObjectFields = []
    compensastionObjectFields = []
    provisioningObjectFields = []
    contactObjectSchema= []
    compensastionObjectSchema = []
    provisioningObjectSchema = []
    objectSchema
    booleanOptions = []
    isDateField = false
    isNumberField = false
    isDateTimeField = false
    isTextField = false
    isBoolean = false
    isPickList = false
    hasRendered = false
    hasExistingRecord = false
    editEventIndex
    editEventObject
    isEditEnabled =  false
    showSpinner = true
    finalQueryString
    companyId
    hasContactCriteria = false
    hasProvisioningCriteria = false
    hasCompensastionCriteria = false
    selectedFieldDataType = ''
    isCustomLogic = false
    hasFilterLogicError = false
    validFilterCharacters = new Set(['and','or','(',')'])
    objectNames = ['Acquisition_Contacts__c','Acquisition_Compensation__c','Acquisition_Provisioning__c']

    get objectOptions() {
        return [
            { label: 'Acquisition Contacts', value: 'Acquisition_Contacts__c' },
            { label: 'Acquisition Compensation', value: 'Acquisition_Compensation__c' },
            { label: 'Acquisition Provisioning', value: 'Acquisition_Provisioning__c' },
        ]
    }

    async handleObjectChange(event){
        const selectedObject = event.target.value
        
        if(selectedObject == 'Acquisition_Contacts__c'){
            this.objectFields = this.contactObjectFields
            this.objectSchema = this.contactObjectSchema
        }else if(selectedObject == 'Acquisition_Compensation__c'){
            this.objectFields = this.compensastionObjectFields 
            this.objectSchema = this.compensastionObjectSchema
        }else if(selectedObject == 'Acquisition_Provisioning__c'){
            this.objectFields = this.provisioningObjectFields 
            this.objectSchema = this.provisioningObjectSchema
        }
    }

    connectedCallback(){
        this.existingCriterias = {}
        this.existingCriterias.Acquisition_Contacts__c = []
        this.existingCriterias.Acquisition_Provisioning__c = []
        this.existingCriterias.Acquisition_Compensation__c = []
        this.existingCriterias.CustomLogics ={'Acquisition_Contacts__c':'','Acquisition_Compensation__c':'','Acquisition_Provisioning__c':''}
        
        Promise.all(
        [
            this.getSchemaCall('Acquisition_Contacts__c'),
            this.getSchemaCall('Acquisition_Compensation__c'),
            this.getSchemaCall('Acquisition_Provisioning__c')
        ]
        ).then(data=>{
            this.showSpinner = false
        })
        
    }
    

    renderedCallback(){
        if(!this.hasRendered && this.recordId != undefined){
            this.getExistingCriteriaCall()
            this.hasRendered = true
        }
    }

    getExistingCriteriaCall(){
        
        getRecordDetails({ recordId : this.recordId})
        .then(data =>{
           
           if(data){
               
                this.companyId = data.Acquisition_Company__c
                if(data.Filter_Criteria_JSON__c != undefined && data.Filter_Criteria_JSON__c != null){
                    this.existingCriterias = JSON.parse(data.Filter_Criteria_JSON__c)
                    console.log(this.existingCriterias)
                    this.existingCriteriasTemp = JSON.parse(JSON.stringify(this.existingCriterias))
                    if(!this.existingCriterias.CustomLogics){
                        this.existingCriterias.CustomLogics = { 'Acquisition_Contacts__c':'',
                                                                'Acquisition_Compensation__c':'',
                                                                'Acquisition_Provisioning__c':''}
                    }
                    if(this.existingCriterias.IsCustomLogic){
                        this.isCustomLogic = true
                    }
                }
                
                this.hasExistingRecord = true
                this.updateSections()
           }
            
        })
        .catch(error =>{
            this.showErroMessage(error)
            console.log(error)
        })
    }

    async getSchemaCall(selectedObject){
        
        this.booleanOptions = [{label:'true',value:'true'},{label:'false',value:'false'}]
        return getFieldsSchema({ objectName : selectedObject})
        .then(data =>{
            let objectFieldsTemp = []
            let objectSchemaTemp = JSON.parse(data)
            
            let sortedKeys = Object.keys(objectSchemaTemp).sort()
           
            for (const key of sortedKeys) {
                objectFieldsTemp.push( { label: objectSchemaTemp[key].fieldLabel, value: key})
            }
            if(selectedObject == 'Acquisition_Contacts__c'){
                this.contactObjectFields = objectFieldsTemp
                this.contactObjectSchema = objectSchemaTemp

            }else if(selectedObject == 'Acquisition_Compensation__c'){
                this.compensastionObjectFields = objectFieldsTemp
                this.compensastionObjectSchema = objectSchemaTemp
            }else if(selectedObject == 'Acquisition_Provisioning__c'){
                this.provisioningObjectFields = objectFieldsTemp
                this.provisioningObjectSchema = objectSchemaTemp
            }
        })
        .catch(error =>{
            this.showErroMessage(error)
            console.log(error)
        })

    }

    async handleFieldChange(event){
        
        let fieldName = event.target.value
        this.fieldName = fieldName
        let fieldSchema = this.objectSchema[fieldName]
        this.selectedFieldDataType = fieldSchema.fieldDataType
        this.operatorOptions = [{ label: 'EQUALS', value: 'EQUALS'}, { label: 'DOES NOT EQUAL', value: 'DOES NOT EQUAL'}]

        if(this.selectedFieldDataType == 'STRING' || this.selectedFieldDataType == 'PICKLIST' || this.selectedFieldDataType == 'URL'){
            this.operatorOptions.push({ label: 'CONTAINS', value: 'CONTAINS'},{ label: 'DOES NOT CONTAIN', value: 'DOES NOT CONTAIN'},{ label: 'STARTS WITH', value: 'STARTS WITH'},{ label: 'ENDS WITH', value: 'ENDS WITH'})
        }
        if(this.selectedFieldDataType == 'DOUBLE' || this.selectedFieldDataType == 'DATE' || this.selectedFieldDataType == 'DATETIME' || this.selectedFieldDataType == 'CURRENCY'){
            this.operatorOptions.push({ label: 'GREATER THAN', value: 'GREATER THAN'},{ label: 'LESS THAN', value: 'LESS THAN'})
            this.operatorOptions.push({ label: 'GREATER THAN EQUALS', value: 'GREATER THAN EQUALS'},{ label: 'LESS THAN EQUALS', value: 'LESS THAN EQUALS'})
        }
        
        this.isDateField        = this.selectedFieldDataType == 'DATE'
        this.isNumberField      = this.selectedFieldDataType == 'DOUBLE' ||  this.selectedFieldDataType == 'CURRENCY'
        this.isDateTimeField    = this.selectedFieldDataType == 'DATETIME' 
        this.isTextField        = this.selectedFieldDataType == 'STRING'  || this.selectedFieldDataType == 'REFERENCE' || this.selectedFieldDataType == 'URL' || this.selectedFieldDataType == 'EMAIL'
        this.isBoolean          = this.selectedFieldDataType == 'BOOLEAN' 
        this.isPickList         = this.selectedFieldDataType == 'PICKLIST'
       
        
        if(this.isPickList){
            this.isPickListFieldOptions = []
            for (const [key, value] of Object.entries(fieldSchema.picklistValues).reverse()) {
                this.isPickListFieldOptions.push({label: key, value,value})
            }
        }
        return true
    }

    SaveFilter(){
        
        if(!this.validateInput()){
            const fieldName     = this.template.querySelector(".fieldName")
            const operator      = this.template.querySelector(".operator")
            const operand       = this.template.querySelector(".operand")
            const objectName    = this.template.querySelector(".objectName")
           
            this.showSpinner = true
            let criteria            = {}
            criteria.fieldName      = fieldName.value
            criteria.fieldLabel     = this.objectSchema[fieldName.value].fieldLabel
            criteria.operator       = operator.value
            criteria.value          = operand.value
            criteria.dataType       = this.objectSchema[fieldName.value].fieldDataType
            criteria.index          = this.existingCriterias[objectName.value].length+1
            
            this.existingCriterias[objectName.value].push(criteria)
            
            this.updateCommunityFilterCall(true)
        }
    }

    validateCondition(objectName){
        let response = {hasError: false, errorMessage : ''}
        const filterLogic = this.template.querySelector("."+objectName)
        if(filterLogic.value == null || filterLogic.value ==''){
            response.hasError = true
            response.errorMessage = MA_Blank_Condition_Error
        }
       
        let filterArray = filterLogic.value.split(/([()\s])/).filter(n => n.trim() != '')
        
        if(!response.hasError){
            let invalidCharacters = ''
            for(let element of filterArray){
                
                if(!/\d/.test(element) && !this.validFilterCharacters.has(element.toLowerCase())){
                    response.hasError = true
                    invalidCharacters += element+','
                }
            }
            if(response.hasError){
                invalidCharacters = invalidCharacters.substring(0,invalidCharacters.lastIndexOf(','))
                response.errorMessage = MA_Invalid_Characters_Error+' '+invalidCharacters
            }
        }

        if(!response.hasError){
            const holder = this.validateParentheses(filterArray)
            if(holder.length !== 0){
                response.hasError = true
                response.errorMessage =  MA_Additional_Character_Error+' '+holder.toString()
            }
        }
        
        filterLogic.setCustomValidity(response.errorMessage)
        filterLogic.reportValidity()
        this.existingCriterias.CustomLogics[objectName] = filterLogic.value
        
        return response.hasError

    }


    validateParentheses(expr){
        const holder = []
        const openBrackets = ['(']
        const closedBrackets = [')']
        for (let letter of expr) {
            if(openBrackets.includes(letter)){
                holder.push(letter)
            }else if(closedBrackets.includes(letter)){
                const openPair = openBrackets[closedBrackets.indexOf(letter)] 
                if(holder[holder.length - 1] === openPair){ 
                    holder.splice(-1,1)
                }else{
                    holder.push(letter)
                    break
                }
            }
        }
        return holder
    }


    validateInput(){
        const fieldName = this.template.querySelector(".fieldName")
        const operator  = this.template.querySelector(".operator")
        const operand   = this.template.querySelector(".operand")
        
        let hasError = false
        if(fieldName.value == null || fieldName.value ==''){
            fieldName.setCustomValidity('Please select field')
            fieldName.reportValidity()
            hasError = true
            
        }else{
            fieldName.setCustomValidity('')
            fieldName.reportValidity()
        }

        if(operator.value == null || operator.value ==''){
            operator.setCustomValidity('Please select operator')
            operator.reportValidity()
            hasError = true
            
        }else{
            operator.setCustomValidity('')
            operator.reportValidity()
        }
        if(operand!=null && (operand?.value == null || operand?.value =='')){
            operand.setCustomValidity('Please enter value')
            operand.reportValidity()
            hasError = true
        }else if(this.selectedFieldDataType == 'EMAIL' && !this.validateEmail(operand?.value)){
            operand.setCustomValidity('Please enter valid email address')
            operand.reportValidity()
            hasError = true
        }else if(operand!=null){
            operand.setCustomValidity('')
            operand.reportValidity()
        }

        return hasError
    }

    updateCommunityFilterCall(param){
        let byPassCustomLogic = false

        if('boolean' === typeof param && param === true){
            byPassCustomLogic = true
        }
        
       
        this.hasFilterLogicError = false
        this.showSpinner = true
        if(!byPassCustomLogic && this.existingCriterias.IsCustomLogic){
        
            let hasError = false
            for(const objectName of this.objectNames){
                if(this.existingCriterias[objectName].length > 0 && this.validateCondition(objectName)){
                    hasError = true
                }
            }
            if(hasError){
                this.showSpinner = false
                return
            }
            
        }

        this.finalQueryString = this.generateQuery()
        if(!this.hasFilterLogicError){
            updateFilterCriteriaJSON({recordId: this.recordId , criteria: JSON.stringify(this.existingCriterias), queryString: this.finalQueryString})
            .then(data =>{
                updateRecord({ fields: { Id: this.recordId } })
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Filter criteria updated sucessful',
                    variant: 'success',
                    mode: 'dismissable'
                })
                this.dispatchEvent(evt)
                

            }).catch(error => {
                console.log(error)
                this.existingCriterias = JSON.parse(JSON.stringify(this.existingCriteriasTemp))
                this.showErroMessage(error)
            }).finally(() => {
                this.showSpinner = false
                this.updateSections()
                this.cancelEdit()
                
            })
        }else{
            console.log('filter logic error')
            this.showSpinner = false
        }
    }

    async editCriteria(event){
        this.editEventIndex     = event.currentTarget.dataset.sequence
        this.editEventObject    = event.currentTarget.dataset.object
        const criteria          = this.existingCriterias[this.editEventObject][this.editEventIndex]
        const customEvent       = {target:{value: criteria.fieldName}}
        const customObjectEvent = {target:{value: this.editEventObject }}
        this.template.querySelector(".objectName").value = this.editEventObject

        await this.handleObjectChange(customObjectEvent)

        this.template.querySelector(".fieldName").value = criteria.fieldName
       
        await this.handleFieldChange(customEvent)
        this.template.querySelector(".operator").value = criteria.operator
        this.template.querySelector(".operand").value = criteria.value
        this.isEditEnabled = true
        window.scrollTo(0, 0);
        
    }

    updateFilter(){

        if(!this.validateInput()){
            const fieldName = this.template.querySelector(".fieldName").value
            this.existingCriterias[this.editEventObject][this.editEventIndex].fieldName = fieldName
            this.existingCriterias[this.editEventObject][this.editEventIndex].fieldLabel = this.objectSchema[fieldName].fieldLabel
            this.existingCriterias[this.editEventObject][this.editEventIndex].operator = this.template.querySelector(".operator").value
            this.existingCriterias[this.editEventObject][this.editEventIndex].value = this.template.querySelector(".operand").value
            this.existingCriterias[this.editEventObject][this.editEventIndex].dataType = this.objectSchema[fieldName].fieldDataType
            this.showSpinner = true
            
            this.updateCommunityFilterCall(true)
            this.isEditEnabled = false
        }
      
    }

    cancelEdit(){
        if(this.template.querySelector(".operator") != null)
            this.template.querySelector(".operator").value = ''
        if(this.template.querySelector(".operand") != null)
            this.template.querySelector(".operand").value = ''
        if(this.template.querySelector(".fieldName") != null)
            this.template.querySelector(".fieldName").value = ''
        this.operatorOptions = []
        this.isTextField = false
        this.isDateField = false
        this.isDateTimeField = false
        this.isNumberField = false
        this.isBoolean = false
        this.isPickList = false
        this.isEditEnabled = false
    }

    deleteCriteria(event){
        this.editEventIndex     = event.currentTarget.dataset.sequence
        this.editEventObject    = event.currentTarget.dataset.object
        

        this.existingCriterias[this.editEventObject].splice(this.editEventIndex, 1)
        
        this.existingCriterias[this.editEventObject].forEach((element,index) => element.index = index+1)
        this.showSpinner = true
        if(this.existingCriterias.IsCustomLogic){
            this.generateDefaultLogic()
        }
        this.updateCommunityFilterCall(true)
        window.scrollTo(0, 0);
    }
    
    updateSections(){
        this.contactCriteria        = this.existingCriterias.Acquisition_Contacts__c
        this.provisioningCriteria   = this.existingCriterias.Acquisition_Provisioning__c
        this.compensastionCriteria  = this.existingCriterias.Acquisition_Compensation__c

        this.hasCompensastionCriteria = this.compensastionCriteria != undefined && this.compensastionCriteria.length > 0
        this.hasProvisioningCriteria  = this.provisioningCriteria != undefined &&  this.provisioningCriteria.length > 0
        this.hasContactCriteria       = this.contactCriteria != undefined &&  this.contactCriteria.length > 0
        
    }

    generateQuery(){
        let aqFilter    = ""
        let compFilter  = ""
        let provFilter  = ""
        if(!this.existingCriterias.IsCustomLogic){
            this.existingCriterias['Acquisition_Contacts__c'].forEach(element=> {
                if(!(element.fieldName == 'Contact_Status__c' && element.value == 'Cancelled')){
                    aqFilter += this.parseCondition(element.operator, element.fieldName, element.value,  element.dataType)
                }
            })
            this.existingCriterias['Acquisition_Compensation__c'].forEach(element => compFilter += this.parseCondition(element.operator, element.fieldName, element.value,  element.dataType))
            this.existingCriterias['Acquisition_Provisioning__c'].forEach(element => provFilter += this.parseCondition(element.operator, element.fieldName, element.value,  element.dataType))
            aqFilter     = aqFilter != "" ?`${this.removeTrailingAnd(aqFilter)} AND Acquisition_Company__c = '${this.companyId}'` : ` Acquisition_Company__c = '${this.companyId}' `
            compFilter   = compFilter != "" ? ` WHERE ${this.removeTrailingAnd(compFilter)} ` : ""
            provFilter   = provFilter != "" ? ` WHERE ${this.removeTrailingAnd(provFilter)} ` : ""
        }else{
            aqFilter   = this.customLogicToQueryCondition('Acquisition_Contacts__c')
            compFilter = this.customLogicToQueryCondition('Acquisition_Compensation__c')
            provFilter = this.customLogicToQueryCondition('Acquisition_Provisioning__c')
            aqFilter     = aqFilter != "" ?`( ${aqFilter} ) AND Acquisition_Company__c = '${this.companyId}'` : ` Acquisition_Company__c = '${this.companyId}' `
            compFilter   = compFilter != "" ? ` WHERE ${compFilter} ` : ""
            provFilter   = provFilter != "" ? ` WHERE ${provFilter} ` : ""

        }
        
        

        let query = `SELECT Id`
        
        query += `, (SELECT Id FROM Acquisition_Compensation__r ${compFilter}) `
        
        query += `, (SELECT Id FROM Acquisition_Provisioning__r ${provFilter}) `
       
        query += ` FROM Acquisition_Contacts__c WHERE ${aqFilter}`
        
       
        query += ` AND Contact_Status__c != 'Cancelled' `
        console.log('final query',query)
        return query
        
    }

    parseCondition(operator, fieldApiName, value, dataType){
        let selectiveFilter = ""
        let isStringField   = this.chekStringField(dataType)
        value =  value.replace(/'/g, "\\'")
        switch(true){
            case (operator === 'EQUALS' && isStringField): 
                selectiveFilter = ` ${fieldApiName} = '${value}' AND `
                break
            case (operator === 'EQUALS' && !isStringField): 
                selectiveFilter = ` ${fieldApiName} = ${value} AND `
                break
            case (operator == 'DOES NOT EQUAL' && isStringField): 
                selectiveFilter = ` ${fieldApiName} != '${value}' AND `
                break
            case (operator == 'DOES NOT EQUAL' && !isStringField): 
                selectiveFilter = ` ${fieldApiName} != ${value} AND `
                break
            case (operator == 'STARTS WITH'): 
                selectiveFilter = ` ${fieldApiName} LIKE '${value}%' AND `
                break
            case (operator == 'ENDS WITH'): 
                selectiveFilter = ` ${fieldApiName} LIKE '%${value}' AND `
                break
            case operator === 'CONTAINS':
                selectiveFilter = ` ${fieldApiName} LIKE '%${value}%' AND `
                break
            case operator === 'DOES NOT CONTAIN':
                selectiveFilter = ` ( NOT ${fieldApiName} LIKE '%${value}%' ) AND `
                break
            case operator === 'GREATER THAN':
                selectiveFilter = `${fieldApiName} > ${value} AND `
                break
            case operator === 'LESS THAN':
                selectiveFilter = `${fieldApiName} < ${value} AND `
                break
            case operator === 'GREATER THAN EQUALS':
                selectiveFilter = `${fieldApiName} >= ${value} AND `
                break
            case operator === 'LESS THAN EQUALS':
                selectiveFilter = `${fieldApiName} <= ${value} AND `
                break
        }
        return selectiveFilter
    }

    chekStringField(dataType){
        return (dataType == 'STRING' || dataType == 'REFERENCE'  || dataType == 'PICKLIST' || dataType == 'URL' || dataType == 'EMAIL')
    }

    removeTrailingAnd(str){
        return str.substring(0,str.lastIndexOf('AND'))
    }

    showErroMessage(error) {
        console.log(error)
        this.showSpinner = false
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : reduceErrors(error), "variant" : "error"}))
    }

    validateEmail(email){
        return String(email)
          .toLowerCase()
          .match(
            /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
          )
    }

    customLogicChecked(event){
        this.isCustomLogic = this.existingCriterias['IsCustomLogic'] = event.target.checked
        this.generateDefaultLogic()
        
    }

    generateDefaultLogic(){
       
        for(const objectName of this.objectNames){
            if(this.existingCriterias.IsCustomLogic){
                let logic = ''
                this.existingCriterias[objectName].forEach(element =>  logic += element.index + ' AND ')
                logic = this.removeTrailingAnd(logic)
                this.existingCriterias.CustomLogics[objectName] =  logic
                
            }else{
                if(!this.existingCriterias.CustomLogics){
                    this.existingCriterias.CustomLogics[objectName] = ""
                }
            }
        }
        if(!this.existingCriterias.IsCustomLogic){
            this.updateCommunityFilterCall()
        }
    }

    customLogicToQueryCondition(objectName){
        const filterLogicInput = this.template.querySelector("."+objectName)
        
        let errorMessage = ''
        let queryFilter = ''

        if(this.existingCriterias.CustomLogics[objectName]){
            const logicString = this.existingCriterias.CustomLogics[objectName].toUpperCase()
            if(logicString.includes('OR') && logicString.includes('AND') && !logicString.includes('(')){
                errorMessage = `Expecting a right parentheses, found 'OR'`
                this.hasFilterLogicError = true
            }
            
            if(errorMessage == ''){
                const filterArray = logicString.split(/([()\s])/).filter(n => n.trim() != '')
                filterArray.forEach(element => {
                    if(this.validFilterCharacters.has(element.toLowerCase())){
                        queryFilter += ' '+element// adding OR/AND in query
                    }else{
                        const index = parseInt(element)-1
                        if(this.existingCriterias[objectName][index]){
                            const eachCondition = this.existingCriterias[objectName][index]
                            queryFilter += ' '+this.removeTrailingAnd(this.parseCondition(eachCondition.operator, eachCondition.fieldName, eachCondition.value,  eachCondition.dataType))
                        }else{
                            errorMessage = `SR No ${element} does not exists`
                            this.hasFilterLogicError = true
                        }
                    }
                })
            }

        }

        filterLogicInput.setCustomValidity(errorMessage)
        filterLogicInput.reportValidity()
        
        return queryFilter
    }

    
}