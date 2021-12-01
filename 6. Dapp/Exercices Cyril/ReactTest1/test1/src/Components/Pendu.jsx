import React, { useState, useEffect } from 'react';

const word = "test";
var playedLetters = [];

const Pendu = () => {

    return (
        <div className="Pendu">
            <Proposals />
        </div>
    )
}

function Proposals(){
    const [currentLetter, setCurrentLetter] = useState('');
    const [letterState, setLetterState] = useState(false);
    const [letterStateMessage, setLetterStateMessage] = useState("En attente d'une lettre...");
    const [countTry, setCountTry] = useState(10);

    useEffect(() => {
        if(countTry === 0){
            
        }
    })

    useEffect(() => {
        if(letterState === true){
            setLetterStateMessage("Good letter");
        }
        else setLetterStateMessage("Wrong letter");
    }, [letterState])

    function submitLetter(){
        setCountTry(countTry - 1);
        setLetterState(checkLetter(currentLetter));
    }

    return (
        <div className="LetterProposalPanel">
            Proposez une lettre:
            <input type="test" size="3" maxLength="1" onChange={e => setCurrentLetter(e.target.value)}></input>
            <input type="button" value="Essayer" onClick={() => submitLetter()}></input>

            <div className="InfosLetter">
                {letterStateMessage}
            </div>
            <div className="InfosTry">
                Essais restants: {countTry}
            </div>
        </div>
    )
}

function checkLetter(c){
    if(playedLetters.includes(c)){
        return false;
    }
    else {
        playedLetters.push(c);
        if(word.includes(c)){
            console.log("true");
            return true;
        }
        else return false;
    }
}

export default Pendu;