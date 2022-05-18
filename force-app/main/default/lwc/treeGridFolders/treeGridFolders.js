import { LightningElement, api, wire,track} from 'lwc';
import getSPFiles from '@salesforce/apex/Callouts.getFiles';
import PATH_FIELD from '@salesforce/schema/Opportunity.SP_path__c'
import getSingleOpportunity from '@salesforce/apex/OpportunityController.getSingleOpportunity';
import { getSObjectValue } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class TreeBasic extends LightningElement {
    // @api exposes a public property (here : Id of the record)
    @api recordId; 

    // @wire is used to read SF data
    @wire(getSingleOpportunity,{recordId:'$recordId'}) 
    opp;

    // @track makes the property reactive and rerenders the component once changed
    @track isLoading = true; 
    @track returnedFolder; 
    @track compName;

    isSelected = false;

    SHAREPOINT_NAME = 'Real_Estate'; // modify this line with your metadata record's name

    get path() {
        return this.opp.data ? getSObjectValue(this.opp.data, PATH_FIELD) : '';
    }

    // is launched automatically when component is inserted in the DOM
    connectedCallback(){
        this.compName = 'Root Folder';
        getSPFiles({
            folderPath: '',
            sharePointName: this.SHAREPOINT_NAME,
            accessToken:''
        }).then(result=>{
            const regEx = /items/g;
            this.returnedFolder = JSON.parse(JSON.stringify(result).replaceAll(regEx,'_children'));
            this.isLoading=false;
        }).catch(error=>{
            console.log(error);
        })
    }

    // fires on 'onClick' events
    handleClick() {
        this.isSelected = !this.isSelected;
        this.isLoading=true;
        console.log('isSelected : ', this.isSelected);
        if(this.isSelected && this.path !== undefined){
            this.compName = this.path;
            getSPFiles({
                folderPath: this.path,
                sharePointName:this.SHAREPOINT_NAME, 
                accessToken:''
            }).then(result=>{
                const regEx = /items/g;
                console.log(result);
                if(Object.keys(result).length !== 0){
                    this.returnedFolder = JSON.parse(JSON.stringify(result).replaceAll(regEx,'_children'));
                }else{
                    this.isSelected = !this.isSelected;
                    this.compName = 'Root Folder';
                    let messageBody = 'Folder Path does not exist or is empty - Folder path entered : ' + this.path;
                    const toastEvt = ShowToastEvent({
                        title: 'Uh-oh! Something went wrong...',
                        message: messageBody,
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvt);
                }
                this.isLoading=false;
            }).catch(error=>{
                console.log(error);
            })
        }else if(!this.isSelected){
            this.compName = 'Root Folder';
            getSPFiles({
            folderPath: '',
            sharePointName:this.SHAREPOINT_NAME,
            accessToken:''
        }).then(result=>{
            console.log(result);
            const regEx = /items/g;
            this.returnedFolder = JSON.parse(JSON.stringify(result).replaceAll(regEx,'_children'));
            this.isLoading=false;
        }).catch(error=>{
            console.log(error);
        });
        }
        else{
            this.isLoading = false;
            this.isSelected = !this.isSelected;
            const evt = ShowToastEvent({
                title: 'No Folder Path Defined!',
                message: 'Fill in the "SP path" field on the object and reload the page to enable navigating to the related folder.',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }


    gridColumns = [
        {
            type: 'url',
            fieldName: 'href',
            label: 'Name',
            typeAttributes : {
                label: {fieldName: 'label'},
            },
            cellAttributes: {
                iconName: { fieldName: 'ldsIconName' },
                iconAlternativeText: '',
            },
        },
        {
            type : 'text',
            fieldName:'metatext',
            label:'Type',
            initialWidth:200,
        },
        {
            type : 'url',
            label:'Link',
            fieldName:'href',
            initialWidth:100,
            typeAttributes : {
                label: {fieldName: 'redirection'},
            },
        }
    ];
}