import { LightningElement,track} from 'lwc';
import getSPFiles from '@salesforce/apex/Callouts.getFiles';

export default class TreeBasic extends LightningElement {

    @track isLoading = true;
    @track folderPath;
    @track returnedFolder;

    SHAREPOINT_NAME = 'Real_Estate';

    connectedCallback() {
        getSPFiles({
            folderPath : '',
            sharePointName:this.SHAREPOINT_NAME,
            accessToken : ''
            }).then(result=>{
                this.returnedFolder = result;
                this.isLoading=false;
                console.log(result);
                console.log('this.name : ' + this.name);
            }).catch(error=>{
                console.log(error);
            }
        )
    }
}