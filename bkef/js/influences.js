window.id = 1000;
window.relevantniObjekty = new Array();
window.kteryObjekt = 0;
window.pocetObjekt = 0;
window.ulozene = 0;
//positiveFrequnecy a negativeFrequency
/*
 Funkce, která se volá v případě, že uživatel klikne v rámci jedné influence na nějaký 
 obrázek. Nastaví barvu všech ostatních na bílou a přenese tento obrázek i do tabulky.
 Následně ještě nastaví doplňkový text k danému typu influence.
*/
function prebarvi(id1) {
	idObrazku = window.vybraneId;
	idPom = id1.substring(id1.search("°")+1);
	idText = id1.substring(0,id1.search("°"));
	if(idText == "positiveFrequency" || idText == "negativeFrequency"){
  		document.getElementById("tlacitko2°"+idPom).style.display = "none";
   		document.getElementById("tlacitko3°"+idPom).style.display = "";
	}
	else{
 		document.getElementById("tlacitko3°"+idPom).style.display = "none";
   		document.getElementById("tlacitko2°"+idPom).style.display = "";
	}
	srcObrOpener = vratSrcObr(id1);
	document.getElementById(idObrazku).src = srcObrOpener;
	pomocnyNazevAtributu = document.getElementById(id1).getAttribute("doplnkoveinfo");
	document.getElementById("bkefdoplnkovytext°"+idPom).innerHTML = document.getElementById(pomocnyNazevAtributu+idPom).innerHTML;
  	id2 = id1;   
  	id1 = obsahujeId(id1);
	document.getElementById(idObrazku).name = id1;
	for (i = 0; i != document.getElementsByTagName("img").length; i++) {
		document.getElementsByTagName("img")[i].style.borderColor = "white";
	}
	zaridSelect(id2,idPom);                    
}
                
/*
Tahle funkce řeší ukrývání a zobrazování prvků typu select a input, které řeší zadávání
doplňkových informací k jednotlivým formátům. 
*/
function zaridSelect(id2, idPom){
	if(document.getElementById(id2).getAttribute("alt") == "Positive Frequency" || document.getElementById(id2).getAttribute("alt") == "Negative Frequency"){
		for(i = 0; i != document.getElementsByName("selectVyberA°"+idPom).length; i++){
			document.getElementsByName("selectVyberA°"+idPom)[i].style.display = "block";
		}
	}
	else{
		for(i = 0; i != document.getElementsByName("selectVyberA°"+idPom).length; i++){
			document.getElementsByName("selectVyberA°"+idPom)[i].style.display = "none";
		}
	}
	if(document.getElementById(id2).getAttribute("alt") == "Positive Frequency" || document.getElementById(id2).getAttribute("alt") == "Negative Frequency"){
		for(i = 0; i != document.getElementsByName("selectVyberBB°"+idPom).length; i++){
			document.getElementsByName("selectVyberBB°"+idPom)[i].style.display = "block";
		}
		for(i = 0; i != document.getElementsByName("selectVyberBLevaZ°"+idPom).length; i++){
			document.getElementsByName("selectVyberBLevaZ°"+idPom)[i].style.display = "block";
		}
		for(i = 0; i != document.getElementsByName("selectVyberBPravaZ°"+idPom).length; i++){
			document.getElementsByName("selectVyberBPravaZ°"+idPom)[i].style.display = "block";
		}
		for(i = 0; i != document.getElementsByName("selectVyberBLeva°"+idPom).length; i++){
			document.getElementsByName("selectVyberBLeva°"+idPom)[i].style.display = "block";
		}
	}
	else{
		for(i = 0; i != document.getElementsByName("selectVyberBB°"+idPom).length; i++){
			document.getElementsByName("selectVyberBB°"+idPom)[i].style.display = "none";
		}
		for(i = 0; i != document.getElementsByName("selectVyberBLevaZ°"+idPom).length; i++){
			document.getElementsByName("selectVyberBLevaZ°"+idPom)[i].style.display = "none";
		}
		for(i = 0; i != document.getElementsByName("selectVyberBPravaZ°"+idPom).length; i++){
			document.getElementsByName("selectVyberBPravaZ°"+idPom)[i].style.display = "none";
		}
		for(i = 0; i != document.getElementsByName("selectVyberBLeva°"+idPom).length; i++){
			document.getElementsByName("selectVyberBLeva°"+idPom)[i].style.display = "none";
		}
	}
}
                
// Folding of particular formats
function ShowHide(id) {
	folding = window.document.getElementById(id).style;
	folding.display = (folding.display == 'block')? 'none': 'block';
}

function ShowHideAll(name) {
	for(i = 0; i < document.getElementsByName(name).length; i++){
		folding = window.document.getElementsByName(name)[i].style;
		folding.display = (folding.display == '')? 'none': '';
		//folding.display = 'none';
	}
}

/* function solveTable(id, korenTabulky){
	cihldren = korenTabulky.childNodes;
	for(k = 0; k < children.length; k++){
		if(children[k].nodeType == Node.ELEMENT_NODE){
			if(children[k].getAttribute("doplnkove") != null){
				if(obsahujeId(children[k].getAttribute("doplnkove")) != -1){
					children[k].setAttribute("doplnkove",obsahujeId(children[k].getAttribute("doplnkove"))+id);				
				}
			}
			if(children[k].getAttribute("id") != null){
				if(obsahujeId(children[k].getAttribute("id")) != -1){
					children[k].setAttribute("id",obsahujeId(children[k].getAttribute("id"))+id);
					children[k].setAttribute("name",obsahujeId(children[k].getAttribute("id"))+id);
				}
			}
			if(children[k].getAttribute("name") != null){
				if(obsahujeId(children[k].getAttribute("name")) != -1){
					children[k].setAttribute("name",obsahujeId(children[k].getAttribute("name"))+id);				
				}
			}
			if(children[k].childNodes.length != 0){
				solveTable(id, children[k]);
			}
		}
	}
} */

/*
 Úvodní funkce, která proběhne hned po nahrání. Nejprve vezme tabulku matrix a předá
 jí funkci nastavTabulku následně u všech checkboxů nastaví jméno. Poté vezme
 všechny divy, tkeré mají id a jejichž id obsahují bkefrestrikce. Tyto divy bere
 kvůli tomu, že v nich jsou uloženy doplňkové informace o tom, které
 hodnoty byly nastaveny v doplňkových údajích k formátům. 
*/
function uvodniNastaveni() {
	for (i = 0; i != document.getElementsByTagName("object").length; i++) {
        if (document.getElementsByTagName("object")[i].getAttribute("id") != null) {
            window.relevantniObjekty[window.pocetObjekt] = document.getElementsByTagName("object")[i];
            window.pocetObjekt++;
        }
    }
	for (i = 0; i != document.getElementsByTagName("table").length; i++) {
		if (document.getElementsByTagName("table")[i].getAttribute("class") == "matrix") {
    		nastavTabulku(document.getElementsByTagName("table")[i]);
		}
	}
	for (i = 0; i < document.getElementsByTagName("input").length; i++) {
		if (document.getElementsByTagName("input")[i].getAttribute("type") == "checkbox") {
    		document.getElementsByTagName("input")[i].setAttribute("name", document.getElementsByTagName("input")[i].getAttribute("doplnkove"));
		}
	}
	for (u = 0; u < document.getElementsByTagName("div").length;u++){
		if(document.getElementsByTagName("div")[u].getAttribute("id") != null){
			if(document.getElementsByTagName("div")[u].getAttribute("id").search("bkefrestrikce") != -1){
				idPom = document.getElementsByTagName("div")[u].getAttribute("id").substring(document.getElementsByTagName("div")[u].getAttribute("id").search("°")+1);
				vyresPuvodniHodnoty(document.getElementsByTagName("div")[u],idPom);
			}
		}
	} 
	for (v = 1000; v < window.id; v++){
		//alert(v+" "+window.id);
		for(p = 1; p < document.getElementById("influence1°"+v).options.length;p++){
			if(document.getElementById("influence1°"+v).options[p].innerHTML == document.getElementById("influence1°"+v).options[0].innerHTML){
				document.getElementById("influence1°"+v).options[p].selected = true;
				document.getElementById("influence1°"+v).options[0].selected = false;
				document.getElementById("influence1°"+v).options[0].value = " - Choose - ";
				document.getElementById("influence1°"+v).options[0].innerHTML = " - Choose - ";
			}
		}
		for(p = 1; p < document.getElementById("knowledge1°"+v).options.length;p++){
			if(document.getElementById("knowledge1°"+v).options[p].getAttribute("type") == document.getElementById("knowledge1°"+v).options[0].innerHTML){
				document.getElementById("knowledge1°"+v).options[p].selected = true;
				document.getElementById("knowledge1°"+v).options[0].selected = false;
				document.getElementById("knowledge1°"+v).options[0].value = " - Choose - ";
				document.getElementById("knowledge1°"+v).options[0].innerHTML = " - Choose - ";
			}
		}
	}                   
}
 
/*
 Projde tabulku, s class matrix a najde v ní všechny buňky, které mají být zpracovány
 a předá je k nastavení funkci nastavBunku
*/
function nastavTabulku(koren) {
     //v rámci jednoho td je potřeba unikátní id.
    var deti = koren.childNodes;
    for (var i = 0; i != deti.length; i++) {
    	if (deti[i].nodeType == Node.ELEMENT_NODE) {
            if (deti[i].nodeName == "TD") {
                if (deti[i].getAttribute("kzpracovani") != null) {
                	//alert(window.relevantniObjekty[window.kteryObjekt]);
                    //nastavBunku(window.relevantniObjekty[window.kteryObjekt]);
                    window.kteryObjekt++;
                    nastavBunku(deti[i]);
                    window.id++;
                }
            }
        }
        nastavTabulku(deti[i]);
    }
}

function solveTextarea(textArea){
	if(textArea.value == "Zde můžete zadat doplňující informace k této závislosti."){
		textArea.value="";
	}
}     

     
/*
	Tato funkce vezme jednu buňku tabulky obsahující nějakou influenci. 
	Následně v jejím rámci nastaví aby měli jednotnou druhou část id, kterou
	je unikátní číslo.
	A v případě jiných prvků než IMG, zařídí, že se do jejich atributu name uloží 
	hodnota id.
*/
function nastavBunku(bunka) {
    var deti = bunka.childNodes;
    
    for (var i = 0; i != deti.length; i++) {
    	if (deti[i].nodeType != Node.ELEMENT_NODE) {
            continue;
        }
        if ((obsahDoplnkove = obsahujeId(deti[i].getAttribute("doplnkove"))) != - 1) {
            deti[i].setAttribute("doplnkove", obsahDoplnkove + window.id);
        }
        if ((obsahId = obsahujeId(deti[i].getAttribute("id"))) != "-1") {
        if(deti[i].nodeName == "INPUT"){
        	//alert(deti[i].nodeName+" "+obsahId);
        	}
            deti[i].setAttribute("id", obsahId + window.id);
            if(deti[i].nodeName != "IMG") {
                deti[i].setAttribute("name", obsahId + window.id);
            }
            //if(deti[i].nodeName != "TEXTAREA"){
            nastavBunku(deti[i]);
            //}
        } else {
            if(deti[i].nodeName != "IMG") {
                deti[i].setAttribute("name", obsahId + window.id);
            }
            nastavBunku(deti[i]);
        }
    }
}
     
/*
 tahle funkce nastaví hodnoty v selectech a v inputech
 týkajících se upřesnění formátů.
*/						  
function vyresPuvodniHodnoty(koren, idPom){
	bkefktery = "";
	if(koren.getAttribute("ktery") == 'B'){
		bkefktery = "1";
	}
	var deti = koren.childNodes;
	var jmena = new Array();
	jmenaPom = 0;
	var hodnoty = new Array();
	hodnotyPom = 0;						  		
  		
  	for (var j = 0; j != deti.length; j++) {
  		if(deti[j].getAttribute("id").search("bkefrformatname") != -1){
  			jmena[jmenaPom] = deti[j].innerHTML;
  			jmenaPom++;
  		}
  		if(deti[j].getAttribute("id").search("enumeration") != -1){
  			hodnoty[hodnotyPom] = deti[j].innerHTML;
  			hodnotyPom++;
  		}
  	}
  	for(k = 0; k != jmena.length; k++){
  		for(i = 0; i != document.getElementsByName("selectVyber"+koren.getAttribute('ktery')+"°"+idPom).length; i++) {
			if(document.getElementsByName("format"+bkefktery+"°"+idPom)[i].getAttribute("value") == jmena[k]) {
				document.getElementsByName("format"+bkefktery+"°"+idPom)[i].checked = true;
                if(document.getElementsByName("selectVyber"+koren.getAttribute("ktery")+"°"+idPom)[i].nodeName == "INPUT") {
                	spravnaHodnota = hodnoty[k].replace("&lt;","<").replace("&gt;",">");
                	document.getElementsByName("selectVyber"+koren.getAttribute("ktery")+"°"+idPom)[i].value = spravnaHodnota;
                }
                else {  
                	if(hodnoty[k] != ""){
                    	hodnoty1 = hodnoty[k].split("°");
                 		for(j = 1; j != document.getElementsByName("selectVyber"+koren.getAttribute("ktery")+"°"+idPom)[i].options.length; j++) {
							for(l = 0; l != hodnoty1.length; l++){
                            	if(document.getElementsByName("selectVyber"+koren.getAttribute("ktery")+"°"+idPom)[i].options[j].innerHTML == hodnoty1[l]) {
                                	document.getElementsByName("selectVyber"+koren.getAttribute("ktery")+"°"+idPom)[i].options[j].selected = true;
                                }
                            }
                        }
                        document.getElementsByName("selectVyber"+koren.getAttribute("ktery")+"°"+idPom)[i].options[0].selected = false;
                    }
                }
            }
        }
    }
}       
	  
	               
     
/*
 Vrátí z idPotomek kus, který neobsahuje unikátní identifikátor vygenerovaný
 XSL transformací, který ale bohužel nebyl dost unikátní.
*/
function obsahujeId(idPotomek) {
    if (idPotomek == null) {
        return - 1;
    }
    if(idPotomek.search("°") == -1) {
        return -1;
    }
    idPotomek = idPotomek.substring(0,idPotomek.search("°"));
    return idPotomek+"°";
}
     
/*
 Prevod mezi jmény obrázku pro lidské oči a jejich reprezentaci pro účely
 samotného skriptu.
*/
function prevedJmeno(jmeno) {
    if (jmeno.search("Some-influence") != "-1") {
        idPom = jmeno.replace("Some-influence", "");
        return "someInfluence" + idPom;
    }
    if (jmeno.search("Positive-growth") != "-1") {
        idPom = jmeno.replace("Positive-growth", "");
        return "positiveInfluence" + idPom;
    }
    if (jmeno.search("Negative-growth") != "-1") {
        idPom = jmeno.replace("Negative-growth", "");
        return "negativeInfluence" + idPom;
    }
    if (jmeno.search("Positive-bool-growth") != "-1") {
        idPom = jmeno.replace("Positive-bool-growth", "");
        return "positiveFrequency" + idPom;
    }
    if (jmeno.search("Negative-bool-growth") != "-1") {
        idPom = jmeno.replace("Negative-bool-growth", "");
        return "negativeFrequency" + idPom;
    }
    if (jmeno.search("Double-bool-growth") != "-1") {
        idPom = jmeno.replace("Double-bool-growth", "");
        return "positiveBoolean" + idPom;
    }
    if (jmeno.search("Negative boolean") != "-1") {
        idPom = jmeno.replace("Negative boolean", "");
        return "negativeBoolean" + idPom;
    }
    if (jmeno.search("Functional") != "-1") {
        idPom = jmeno.replace("Functional", "");
        return "functional" + idPom;
    }
    if (jmeno.search("None") != "-1") {
        idPom = jmeno.replace("None", "");
        return "none" + idPom;
    }
    if (jmeno.search("Uninteresting") != "-1") {
        idPom = jmeno.replace("Uninteresting", "");
        return "doNotCare" + idPom;
    }
    if (jmeno.search("Unknown") != "-1") {
        idPom = jmeno.replace("Unknown", "");
        return "unknown" + idPom;
    }
    if (jmeno.search("Not Set") != "-1") {
        idPom = jmeno.replace("Not Set", "");
        return "notSet" + idPom;
    }
    return jmeno;
}
     
/*
 Prevod mezi jmény obrázku pro lidské oči a jejich reprezentaci pro účely
 samotného skriptu. Jenom v opačném směru než prevedJmeno
*/
function prevedJmenoInv(jmeno) {
    if (jmeno.search("someInfluence") != "-1") {
        return "Some-influence";
    }
    if (jmeno.search("positiveInfluence") != "-1") {
        return "Positive-growth";
    }
    if (jmeno.search("negativeInfluence") != "-1") {
        return "Negative-growth";
    }
    if (jmeno.search("positiveFrequency") != "-1") {
        return "Positive-bool-growth";
    }
    if (jmeno.search("negativeFrequency") != "-1") {
        return "Negative-bool-growth";
    }
    if (jmeno.search("positiveBoolean") != "-1") {
        return "Double-bool-growth";
    }
    if (jmeno.search("negativeBoolean") != "-1") {
        return "Negative boolean";
    }
    if (jmeno.search("functional") != "-1") {
        return "Functional";
    }
    if (jmeno.search("none") != "-1") {
        return "None";
    }
    if (jmeno.search("doNotCare") != "-1") {
        return "Uninteresting";
    }
    if (jmeno.search("unknown") != "-1") {
        return "Unknown";
    }
    if (jmeno.search("notSet") != "-1") {
        return "Not Set";
    }
    return jmeno;
}
     
/*
 Funkce, která se spustí pokaždé když klikne někdo myší na buňku obsahující
 influenci. Ukáže nabídku pro nastavování této influence, případně ji schová 
 pokud byla ukázaná. 
*/
function spust(idShow, id, jmeno) {
	window.aktivniId = id;
    if (document.getElementById(idShow).style.display == 'block') {
        skonci(idShow);
    } else {
		if (zkontrolujZdaJePouzeJeden()){
	        window.vybraneJmeno = prevedJmeno(jmeno);
            window.vybraneId = id;
            idPom = idShow.substring(idShow.search("°")+1);
            idText = jmeno.substring(0,jmeno.search("°"));
            if(idText == "positiveFrequency" || idText == "negativeFrequency"){
            	document.getElementById("tlacitko2°"+idPom).style.display = "none";
            	document.getElementById("tlacitko3°"+idPom).style.display = "";
            }
            else{
            	document.getElementById("tlacitko3°"+idPom).style.display = "none";
            	document.getElementById("tlacitko2°"+idPom).style.display = "";
            }
            document.getElementById(prevedJmeno(jmeno)).style.borderColor = "black";
            pomocnyNazevAtributu = document.getElementById(prevedJmeno(jmeno)).getAttribute("doplnkoveinfo");
            document.getElementById("bkefdoplnkovytext°"+idPom).innerHTML = document.getElementById(pomocnyNazevAtributu+idPom).innerHTML;
			zaridSelect(prevedJmeno(jmeno), idPom);  
			var pozice = findPos(document.getElementById("content"));
			document.getElementById(idShow).style.top = pozice[1]+"px"; 
			document.getElementById(idShow).style.left = pozice[0]+"px";                       
            ShowHide(idShow);
        }
    }
}

function findPos(obj) {
   var curleft = curtop = 0;
   if (obj.offsetParent) {
     do {
		 curleft += obj.offsetLeft;
		 curtop += obj.offsetTop;
	  } while (obj = obj.offsetParent);
	return [curleft,curtop];
	}
}
     
function jsouZadane(){
	jeOznaceno = true; 	
	for (l = 0; l != document.getElementsByTagName("object").length; l++) {
		koren = document.getElementsByTagName("object")[l]; 
		idPom = koren.getAttribute("id").substring(koren.getAttribute("id").search("°")+1);
    	influenceType = document.getElementById("obrazek°" + idPom).getAttribute("name");
    	//alert("InflTyp"+influenceType);	
		if(influenceType == "positiveFrequency°" || influenceType == "negativeFrequency°") {	
			// tohle je potreba odkomentovat v případě, že bude potřeba aby byly zadány 
			// doplňující údaje u obou atributů a ne jen u toho pravého.		
			/* for(i = 0; i != document.getElementsByName("selectVyberA°"+idPom).length; i++) { 
	    		if(document.getElementsByName("format°"+idPom)[i].checked) {
	    			if(document.getElementsByName("selectVyberA°"+idPom)[i].nodeName == "INPUT") {
	                	if(document.getElementsByName("selectVyberA°"+idPom)[i].value == ""){
	                		jeOznaceno = false; 
	                	}
	            	} 
	            	if(document.getElementsByName("selectVyberA°"+idPom)[i].nodeName == "SELECT"){
	               		m = 0;                             
	               		for(j = 1; j != document.getElementsByName("selectVyberA°"+idPom)[i].options.length; j++) {
	                  		if(document.getElementsByName("selectVyberA°"+idPom)[i].options[j].selected) {
	                    		m++;
	                  		}
	               		} 
	               		if(m == 0){
	               	  		jeOznaceno = false;
	               		}
	            	}
	        	}
	    	} */
	     
	    	for(i = 0; i != document.getElementsByName("selectVyberB°"+idPom).length; i++) {
	        	if(document.getElementsByName("format1°"+idPom)[i].checked) { 
	            	if(document.getElementsByName("selectVyberB°"+idPom)[i].nodeName == "INPUT") {
	            		if(document.getElementsByName("selectVyberB°"+idPom)[i].value == ""){
	                		jeOznaceno = false; 
	                		alert("Nezadal jste doplňující údaje týkající se formátu na pravé straně závislosti. \nAtribut A je: "+document.getElementById("jmenoatr0°"+idPom).innerHTML+"\nAtribut B je: "+document.getElementById("jmenoatr1°"+idPom).innerHTML);
	                	}
	            	}
	            	if(document.getElementsByName("selectVyberB°"+idPom)[i].nodeName == "SELECT"){  
	            		m = 0;                          
	                	for(j = 1; j != document.getElementsByName("selectVyberB°"+idPom)[i].options.length; j++) {
	                    	if(document.getElementsByName("selectVyberB°"+idPom)[i].options[j].selected) {
								m++;                             
	                    	}
	                	}
	                	if(m == 0){
	                		jeOznaceno = false;
	                		alert("Nezadal jste doplňující údaje týkající se formátu na pravé straně závislosti. \nAtribut A je: "+document.getElementById("jmenoatr0°"+idPom).innerHTML+"\nAtribut B je: "+document.getElementById("jmenoatr1°"+idPom).innerHTML);
	                	}
	            	}
	        	}
	    	}
	    
	    for(i = 0; i != document.getElementsByName("selectVyberBB°"+idPom).length; i++) {
	        	if(document.getElementsByName("format1°"+idPom)[i].checked) { 
	            	if(document.getElementsByName("selectVyberBB°"+idPom)[i].value == "" || document.getElementsByName("selectVyberBLeva°"+idPom)[i].value == ""){
	                	jeOznaceno = false; 
	                	alert("Nezadal jste doplňující údaje týkající se formátu na pravé straně závislosti. \nAtribut A je: "+document.getElementById("jmenoatr0°"+idPom).innerHTML+"\nAtribut B je: "+document.getElementById("jmenoatr1°"+idPom).innerHTML);
	            	}
	        	}
	    	}
	    }
	}
	//alert(jeOznaceno);
	return jeOznaceno;
}     
     
/*
 Funkce, která se spouští při odesílání formuláře. Vezme všechny relevantní údaje
 které známe o jednotlivých buňkách tabulky matrix a nacpe je do inputů typu hidden
 které následně umí zpracovat PHP do výsledného XML dokumentu. 
*/
function zpracuj(doplnkove) {
	if(!jsouZadane()){
    	
     	return false;
    }
    if(window.ulozene == 0){
    window.ulozene = 1;
    var pocet = document.createElement("input");
    pocet.setAttribute("id", "pocetprvkubkef");
    pocet.setAttribute("name", "pocetprvkubkef");
    pocet.setAttribute("type", "hidden");
    pocet.setAttribute("value", "0");
    var k = 0;
    document.getElementById("formularInfluences").appendChild(pocet);
    for (l = 0; l != document.getElementsByTagName("object").length; l++) {
        if (document.getElementsByTagName("object")[l].getAttribute("id") != null) {
            hodnotaH = zpracujJednuInfluenci(document.getElementsByTagName("object")[l], k);
            
	        if(hodnotaH == -1) {
            	continue;
            }
             //alert(hodnotaH);
             
             var influence = document.createElement("input");
             influence.setAttribute("name", "prvekbkef" + k);
             influence.setAttribute("type", "hidden");
             
             // abych v PHP věděl kolik a jakých prvků.
             pocetPom = document.getElementById("pocetprvkubkef").getAttribute("value");
             pocetPom++;
             document.getElementById("pocetprvkubkef").setAttribute("value", pocetPom);
             
             //influence.setAttribute("value", hodnotaH);
             document.getElementById("formularInfluences").appendChild(influence);
             k++;
        }
    }
     
    //alert("Tady");
    document.getElementById("formularInfluences").submit();
    }
    //Postupně po jedné beru všechny Influences, které nejsou ve stavu Not Set a následně z nich vytvářím hiddeny
    //jedné Influence odpovídá jeden object, který má id
    //return false;
}
     
/*
 Vytvoří jeden prvek input typu hidden s údaji, které mu jsou zadány. 
 Používá se při odeslání formuláře funkcí zpracujJednuInfluenci
*/
function vytvorHidden(inflId, value, jmeno) {
	var influence = document.createElement("input");
	//aalert("Jmeno: "+jmeno+inflId+" "+value);
    influence.setAttribute("name", jmeno + inflId);
    influence.setAttribute("type", "hidden");
    influence.setAttribute("value", value);
    document.getElementById("formularInfluences").appendChild(influence);
}

function zpracujAnotaci(idPom, inflId){
	vytvorHidden(inflId,document.getElementsByName("autorAnotace°"+idPom).length,"pocetAnotaci");
	for(i = 0; i < document.getElementsByName("autorAnotace°"+idPom).length; i++){
		vytvorHidden(inflId,document.getElementsByName("autorAnotace°"+idPom)[i].value,"Tautor"+i+"Anotace");
		vytvorHidden(inflId,document.getElementsByName("textAnotace°"+idPom)[i].value,"Ttext"+i+"Anotace");
	}
}

/*
 Zpracuje jednu konkrétní buňku tabulky při odesílání do formy, kterou umí PHP převést
*/
function zpracujJednuInfluenci(koren, inflId) {
 //pro kazdou vec jeden input hidden
	idPom = koren.getAttribute("id").substring(koren.getAttribute("id").search("°")+1);
    influenceType = prevedJmenoInv(document.getElementById("obrazek°" + idPom).getAttribute("name"));
    if(influenceType != "Not Set") {
        
    	influenceId = inflId;
         
        influenceArity = "2";
         
        knowledgeValidity = "";
        if(document.getElementById("knowledge1°"+idPom).selectedIndex != 0) {
        	knowledgeValidity = document.getElementById("knowledge1°"+idPom).options[document.getElementById("knowledge1°"+idPom).selectedIndex].getAttribute("type");
        }
        
        zpracujAnotaci(idPom, inflId);
        //annotation = document.getElementById("anotace°"+idPom).value;
        //if(annotation == "Zde můžete zadat doplňující informace k této závislosti."){
        //	annotation = "";
        //}
        //alert(anotace);
                                     
        influenceScope = "";
        if(document.getElementById("influence1°"+idPom).selectedIndex != 0) {
            influenceScope = document.getElementById("influence1°"+idPom).options[document.getElementById("influence1°"+idPom).selectedIndex].innerHTML;
        }
         
        metaNameA = "";
        metaNameA = document.getElementById("jmenoatr0°"+idPom).innerHTML;
         
        metaNameB = "";
        metaNameB = document.getElementById("jmenoatr1°"+idPom).innerHTML;
         
        formatNameA = "";
         //projdou se chekboxy a zjisti se checked a nasledne value
        for(i = 0; i!= document.getElementsByName("format°"+idPom).length; i++) {
            if(document.getElementsByName("format°"+idPom)[i].checked) {
                formatNameA += document.getElementsByName("format°"+idPom)[i].getAttribute("value")+"Ł";
            }
        }
         
        formatNameB = "";
        for(i = 0; i!= document.getElementsByName("format1°"+idPom).length; i++) {
            if(document.getElementsByName("format1°"+idPom)[i].checked) {
                formatNameB += document.getElementsByName("format1°"+idPom)[i].getAttribute("value")+"Ł";
            }
        }
         
        valuesA = "";
        for(i = 0; i != document.getElementsByName("selectVyberA°"+idPom).length; i++) {
        	if(document.getElementsByName("format°"+idPom)[i].checked) {
            	if(document.getElementsByName("selectVyberA°"+idPom)[i].nodeName == "INPUT") {
                	valuesA += document.getElementsByName("selectVyberA°"+idPom)[i].value; 
                     
                }
                else {                            
                    for(j = 1; j != document.getElementsByName("selectVyberA°"+idPom)[i].options.length; j++) {
                		if(document.getElementsByName("selectVyberA°"+idPom)[i].options[j].selected) {
                        	valuesA = valuesA + document.getElementsByName("selectVyberA°"+idPom)[i].options[j].value + "°";
                             
                        }
                    }
                }
                valuesA += "Ł";
            }
        }
         
        valuesB = "";
        if(influenceType == "Positive-bool-growth" || influenceType == "Negative-bool-growth"){ 
        	for(i = 0; i != document.getElementsByName("selectVyberB°"+idPom).length; i++) {
            	if(document.getElementsByName("format1°"+idPom)[i].checked) { 
            		if(document.getElementsByName("selectVyberB°"+idPom)[i].nodeName == "INPUT") {
                    	valuesB += document.getElementsByName("selectVyberB°"+idPom)[i].value; 
                	}
                	else {                            
                    	for(j = 1; j != document.getElementsByName("selectVyberB°"+idPom)[i].options.length; j++) {
                    	    if(document.getElementsByName("selectVyberB°"+idPom)[i].options[j].selected) {
                    	        valuesB = valuesB + document.getElementsByName("selectVyberB°"+idPom)[i].options[j].value + "°";
                    	    }
                    	}
                	}
                	valuesB += "Ł";
                }
            }
        }
        for(i = 0; i != document.getElementsByName("selectVyberBB°"+idPom).length; i++) {
            if(document.getElementsByName("format1°"+idPom)[i].checked) {
            	if(influenceType == "Positive-bool-growth" || influenceType == "Negative-bool-growth"){ 
            		if(document.getElementsByName("selectVyberBB°"+idPom)[i].value != "" && document.getElementsByName("selectVyberBLeva°"+idPom)[i].value != ""){
            			for(j = 0; j != document.getElementsByName("selectVyberBLevaZ°"+idPom)[i].options.length; j++) {
                    	    if(document.getElementsByName("selectVyberBLevaZ°"+idPom)[i].options[j].selected) {
                    	        zavorkaL = document.getElementsByName("selectVyberBLevaZ°"+idPom)[i].options[j].innerHTML;
                    	    }
                    	    if(document.getElementsByName("selectVyberBPravaZ°"+idPom)[i].options[j].selected) {
                    	        zavorkaP = document.getElementsByName("selectVyberBPravaZ°"+idPom)[i].options[j].innerHTML;
                    	    }
                    	}
                		valuesB += zavorkaL+document.getElementsByName("selectVyberBLeva°"+idPom)[i].value+";"+document.getElementsByName("selectVyberBB°"+idPom)[i].value+zavorkaP; 
                		valuesB += "Ł";
                	}
                }
            }
        }
        valuesB = valuesB.replace("&lt;","<");
        valuesB = valuesB.replace("&gt;",">");
         
        vytvorHidden(inflId,influenceType,"infltype");
        vytvorHidden(inflId,influenceId,"inflid");
        vytvorHidden(inflId,influenceArity,"inflarity");
        vytvorHidden(inflId,knowledgeValidity,"knowval");
        vytvorHidden(inflId,influenceScope,"inflscope");
        vytvorHidden(inflId,metaNameA,"metanaa");
        vytvorHidden(inflId,metaNameB,"metanab");
        vytvorHidden(inflId,formatNameA,"formnaa");
        vytvorHidden(inflId,formatNameB,"formnab");
        vytvorHidden(inflId,valuesA,"valuesa");
        vytvorHidden(inflId,valuesB,"valuesb");
        //vytvorHidden(inflId,annotation,"annotation");
	   //alert(valuesA+" "+valuesB+" "+formatNameA+" "+formatNameB);	             
    }
    else{
    	return -1;
    }
	return "";
}
  
/*
 Funkce, která se volá při stisku tlačítka ulož v rámci jedné buňkuy tabulky matrix,
 neboli u jedné influence.
*/
function skonci(idShow) {
    ShowHide(idShow);
    zpracuj(idShow);
    window.aktivniId = null;
}


 
                 
/*
 Na základě názvu obrázku vrátí cestu k danému obrázku. 
*/
function vratSrcObr(id) {
    if (id.search("notSet") != - 1) {
        return cestaKObrazku + "notSet.png";
    }
    if (id.search("doNotCare") != - 1) {
        return cestaKObrazku + "doNotCare.png";
    }
    if (id.search("functional") != - 1) {
        return cestaKObrazku + "functional.png";
    }
    if (id.search("negativeBoolean") != - 1) {
        return cestaKObrazku + "negativeBoolean.png";
    }
    if (id.search("negativeFrequency") != - 1) {
        return cestaKObrazku + "negativeFrequency.png";
    }
    if (id.search("negativeInfluence") != - 1) {
        return cestaKObrazku + "negativeInfluence.png";
    }
    if (id.search("none") != - 1) {
        return cestaKObrazku + "none.png";
    }
    if (id.search("positiveBoolean") != - 1) {
        return cestaKObrazku + "positiveBoolean.png";
    }
    if (id.search("positiveFrequency") != - 1) {
        return cestaKObrazku + "positiveFrequency.png";
    }
    if (id.search("positiveInfluence") != - 1) {
        return cestaKObrazku + "positiveInfluence.png";
    }
    if (id.search("someInfluence") != - 1) {
        return cestaKObrazku + "someInfluence.png";
    }
    if (id.search("unknown") != - 1) {
        return cestaKObrazku + "unknown.png";
    }
}
 
function pridejAnotaci(radek1, id){
	radek = radek1.parentNode.parentNode;
	idPom = id.substring(id.search("°")+1);
	kamVlozit = radek.rowIndex;
	novyRadek1 = radek.parentNode.insertRow(kamVlozit);
	//vytvořím s obsahem Autor: a pak s inputem
	bunka11 = novyRadek1.insertCell(0);
	bunka11.innerHTML = "Autor: ";
	bunka12 = novyRadek1.insertCell(1);
	input1 = bunka12.appendChild(document.createElement("input"));
	input1.setAttribute("type","text");
	input1.setAttribute("name","autorAnotace°"+idPom);
	//alert(prihlasenyUzivatel);
	input1.setAttribute("value",prihlasenyUzivatel);
	bunka12.colSpan = 5;
	novyRadek2 = radek.parentNode.insertRow(kamVlozit+1);
	bunka21 = novyRadek2.insertCell(0);
	bunka21.innerHTML = "Text: ";
	bunka22 = novyRadek2.insertCell(1);
	bunka22.colSpan = 5;
	textarea2 = bunka22.appendChild(document.createElement("textarea"));
	textarea2.setAttribute("cols","50");
	textarea2.setAttribute("rows","5");
	textarea2.setAttribute("name","textAnotace°"+idPom);
}
 
function zkontrolujZdaJePouzeJeden(){
	otevreno = 0;
 	for(i = 0; i < document.getElementsByTagName("object").length; i++){ 
 		if(document.getElementsByTagName("object")[i].style.display != "none" && document.getElementsByTagName("object")[i].style.display != ""){
 			otevreno++; 
 		}
 	}
 	if(otevreno < 1){
 		return true;
 	}
 	return false;
}
