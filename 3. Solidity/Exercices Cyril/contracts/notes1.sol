pragma solidity 0.8.9;

contract notes1 {
    /** @notice define the structure of 'Etudiant' */
    struct Etudiant{
        uint noteBiology;
        uint noteMaths;
        uint noteFr;
        bool pass;
    }
    mapping (string => Etudiant) private etudiants;
    string[] dbEtudiants;
    address profBio;
    address profMaths;
    address profFr;
    address directeur;

    constructor(
        address _directeur, 
        address _profBio, 
        address _profMaths, 
        address _profFr
        ){
            directeur = _directeur;
            profBio = _profBio;
            profMaths = _profMaths;
            profFr = _profFr;
    }

    function addEtudiant(string memory _name) external {
        etudiants[_name] = Etudiant(0, 0, 0, false);

        emit newEtudiant(_name);
    }

    function getEtudiant(string memory _name) external view returns(Etudiant memory){
        return etudiants[_name];
    }
    
    function setNoteBio(string memory _name, uint _note) external {
        require(msg.sender == profBio);
        require(_note <= 20, "invalid note");
        etudiants[_name].noteBiology = _note;
        emit newNoteBio(_name, _note);
    }

    function setNoteMaths(string memory _name, uint _note) external {
        require(msg.sender == profMaths);
        require(_note <= 20, "invalid note");
        etudiants[_name].noteMaths = _note;
        emit newNoteMaths(_name, _note);
    }

    function setNoteFr(string memory _name, uint _note) external {
        require(msg.sender == profFr);
        require(_note <= 20, "invalid note");
        etudiants[_name].noteFr = _note;
        emit newNoteFr(_name, _note);
    }

    function moyClasseMatieres() public returns(uint moyBio, uint moyMaths, uint moyFr){
        require(msg.sender == directeur);
        uint totalMoyBio;
        uint totalMoyMaths;
        uint totalMoyFr;

        for(uint i=0; i < dbEtudiants.length; i++){
            etudiants[dbEtudiants[i]].noteBiology += totalMoyBio;
            etudiants[dbEtudiants[i]].noteMaths += totalMoyMaths;
            etudiants[dbEtudiants[i]].noteFr += totalMoyFr;
        }

        totalMoyBio = totalMoyBio / dbEtudiants.length;
        totalMoyMaths = totalMoyMaths / dbEtudiants.length;
        totalMoyFr = totalMoyFr / dbEtudiants.length;

        return(totalMoyBio, totalMoyMaths, totalMoyFr);
    }

    function moyGeneralEtudiant(string memory _name) external returns(uint){
        require(msg.sender == directeur);
        uint totalMoyBio;
        uint totalMoyMaths;
        uint totalMoyFr;
        uint moyG;

        etudiants[_name].noteBiology += totalMoyBio;
        etudiants[_name].noteMaths += totalMoyMaths;
        etudiants[_name].noteFr += totalMoyFr;

        moyG = (totalMoyBio + totalMoyMaths + totalMoyFr) / 3;
        if(moyG > 10){
            etudiants[_name].pass = true;
        }
        return moyG;
    }

    function moyGeneraleClasse() external returns(uint){
        require(msg.sender == directeur);
        uint moy1;
        uint moy2;
        uint moy3;
        uint moyG;

        (moy1, moy2, moy3) = moyClasseMatieres();
        moyG = (moy1 + moy2 + moy3) / 3;
        return moyG;
    }

    function passed(string memory _name) external view returns(bool){
        return etudiants[_name].pass;
    }

    event newEtudiant(string name);
    event newNoteBio(string etudiantName, uint note);
    event newNoteMaths(string etudiantName, uint note);
    event newNoteFr(string etudiantName, uint note);
}