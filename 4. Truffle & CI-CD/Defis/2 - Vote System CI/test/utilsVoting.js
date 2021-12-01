const { BN, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

module.exports = {
    Voting: artifacts.require("Voting"),
    
    //define the account number of each person
    admin: 0,
    voter1: 1,
    voter2: 2,
    voter3: 3,


     /* ::::::::::::::: Utils Functions ::::::::::::::: */

 
     /** 
     *  @description as our contract doesn't have any fonction to retrieve the proposals array,
     *  we need to do it manually by calling each elements of the array.
     *  @param instance The contract instance to get the datas from
     *  @returns an array containing all the called datas from the contract array
     */
    getProposalsArray: async function (instance){
        let proposals = [];
        try{
            for(let i = 0; true; i++){
                let proposalObject = await instance.proposalsArray.call(i);
                proposals.push(proposalObject);
            }      
        }
        catch{
            return proposals;
        }
    },

    /** 
    *  @description used to verify if a state is changing as expected
    *  @dev as we change the state multiples times during the use of the contract,
      this function avoid to write the same tests multiple times with just different states to test
    *  @param previousState the previous (current when called) state
    *  @param expectedNewState the new state, expected to be the new current one at the end of function
    *  @param instance the contract instance to get and set state
    *  @param stateChangeFn the function to use to set the new state
    */
    testStateChange: async function (
        previousState,
        expectedNewState,
        instance,
        stateChangeFn
    ) {
        let currentState = await instance.workflowStatus.call();

        //verifyng that the state 'previousState' to change is correct
        expect(currentState).to.be.bignumber.equal(new BN(previousState));

        //changing the state to the 'expectedNewStatus'
        let receipt = await stateChangeFn();
        currentState = await instance.workflowStatus.call();

        //verifyng that the current state 'currentState' is changed to the new state 'expectedNewStatus'
        expectEvent(
            receipt,
            'WorkflowStatusChange',
            {_previousStatus: new BN(previousState), _newStatus: new BN(expectedNewState)}
        );  
        expect(currentState).to.be.bignumber.equal(new BN(expectedNewState));
    }
}