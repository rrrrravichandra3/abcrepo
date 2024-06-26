/**
 * W-12578110
 * Contains exportable functions (function logic), to validate the Custom Rule Logic expression, used within the M&A Docusign LWC components.
 * 
 * Version      Date            Author                  Description
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/03/2023      Chakshu Malhotra        W-12578110 - Adds exportable functions (function logic), to validate the Custom Rule Logic expression, used within the M&A Docusign LWC components.
 * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import {ruleLogicValidatorLabels} from 'c/madsUtils';

const validateRuleLogic = (ruleLogicStr, rulesCount) => {
    let logicValidity = "";
	let ruleLogicHolder = [];
	let openBracketIndexList = [];
    let ruleNumberSet = new Set();

    const ruleLogicArray = getRuleLogicArray(ruleLogicStr);

    if(isIncompleteRuleLogic(ruleLogicArray, rulesCount)) {
        return ruleLogicValidatorLabels.incompleteLogicValidity;
    }

    for(let logicIndex=0; logicIndex < ruleLogicArray.length; logicIndex++) {
        const logicElement = ruleLogicArray[logicIndex];
        logicValidity = isValidLogicElement(logicElement) ? "" : ruleLogicValidatorLabels.spellingValidity;

        if(logicValidity != "") {
			break;
		}

        if(isNumberLogicElement(logicElement)) {
            logicValidity = getRuleNumberValidity(parseInt(logicElement), rulesCount, ruleNumberSet);
            if(logicValidity != "") {
                break;
            }
            ruleNumberSet.add(parseInt(logicElement));
        }

        ruleLogicHolder.push(logicElement);

        if(logicElement === "(") {
            openBracketIndexList.push(ruleLogicHolder.length - 1);
        }else if(logicElement === ")") {
            const openBracketIndex = openBracketIndexList.pop();
            logicValidity = (openBracketIndex === undefined) ? ruleLogicValidatorLabels.openParenthesisValidity : 
                                                               getRuleLogicHolderValidity(ruleLogicHolder, openBracketIndex);
        }

        if(logicValidity != "") {
            break;
        }
    }

    return (logicValidity != "") ? logicValidity : (ruleLogicHolder.length > 1) ? getRuleLogicHolderValidity(ruleLogicHolder, 0) : "";
};

const getRuleLogicArray = (ruleLogicStr) => {
    return ruleLogicStr.split(/([()\s])/)
           .filter(logicElement => logicElement.trim() != "")
           .map(logicElement => logicElement.toUpperCase());
};

const isIncompleteRuleLogic = (ruleLogicArray, rulesCount) => {
    const ruleNumberSet = new Set(Array.from({"length": rulesCount}, (_, index) => index + 1));
    
    ruleLogicArray.forEach((logicElement) => {
        if(isNumberLogicElement(logicElement)) {
            ruleNumberSet.delete(parseInt(logicElement));
        }
    });    
    return (ruleNumberSet.size > 0);
};

const isValidLogicElement = (logicElement) => {
    const ruleElementRegex = /^([()]|(\d+)|(AND)|(OR))$/
	return ruleElementRegex.test(logicElement);
};

const isNumberLogicElement = (logicElement) => {
	const ruleNumberRegex = /^\d+$/
	return ruleNumberRegex.test(logicElement);
};

const getRuleNumberValidity = (ruleNumber, rulesCount, ruleNumberSet) => {
    let ruleNumberValidity = (ruleNumber < 1 || ruleNumber > rulesCount) ? getUndefinedRuleLogicValidity(ruleNumber) : "";
    return (ruleNumberValidity === "") ? (ruleNumberSet.has(ruleNumber) ? getDuplicateRuleLogicValidity(ruleNumber) : "") : ruleNumberValidity;
};

const getUndefinedRuleLogicValidity = (ruleNumber) => {
    return `${ruleLogicValidatorLabels.undefinedLogicValidity} ${ruleNumber}`;
};

const getDuplicateRuleLogicValidity = (ruleNumber) => {
    return `${ruleLogicValidatorLabels.duplicateLogicValidity} ${ruleNumber}`;
};

const getRuleLogicHolderValidity = (ruleLogicHolder, openBracketIndex) => {
    const closedBracketIndex = ruleLogicHolder.length - 1;
    const splicedElementCount = closedBracketIndex - openBracketIndex + 1;

    if(!isValidMinimumExpressionLength(splicedElementCount)) {
        return ruleLogicValidatorLabels.spellingValidity;
    }

    const logicExprArray = ruleLogicHolder.splice(openBracketIndex, splicedElementCount);
    
    if(!isValidFirstElement(logicExprArray[0])) {
        return ruleLogicValidatorLabels.spellingValidity;
    }
    if(!isValidLastElement(logicExprArray[0], logicExprArray[logicExprArray.length - 1])) {
        return ruleLogicValidatorLabels.rightOperandValidity;
    }

    const exprStartIndex = getExprStartIndex(logicExprArray[0]);
    const exprLastIndex = (exprStartIndex === 0) ? logicExprArray.length - 1 : logicExprArray.length - 2;
    const exprLength = exprLastIndex - exprStartIndex + 1;

    if(exprLength < 3 || !isNumberLogicElement(logicExprArray[exprStartIndex]) || !isNumberLogicElement(logicExprArray[exprLastIndex])) {
        return ruleLogicValidatorLabels.spellingValidity;
    }

    if(!parenthesisValidity(logicExprArray, exprStartIndex, exprLastIndex, "(")) {
        return ruleLogicValidatorLabels.closedParenthesisValidity;
    }

    if(!parenthesisValidity(logicExprArray, exprStartIndex, exprLastIndex, ")")) {
        return ruleLogicValidatorLabels.openParenthesisValidity;
    }

    if(!successiveRuleNumbersValidity(logicExprArray, exprStartIndex, exprLastIndex)) {
        return ruleLogicValidatorLabels.successiveRulesValidity;
    }

    if(!successiveAndOrValidity(logicExprArray, exprStartIndex, exprLastIndex)) {
        return ruleLogicValidatorLabels.successiveAndOrValidity;
    }

    ruleLogicHolder.push("0");
    
    return "";
};

const isValidMinimumExpressionLength = (splicedElementCount) => {
    return (splicedElementCount >= 3 && splicedElementCount % 2 === 1);
};

const isValidFirstElement = (firstElement) => {
    return (isNumberLogicElement(firstElement) || firstElement === "(");
};

const isValidLastElement = (firstElement, lastElement) => {
    return (firstElement === "(" && lastElement === ")") || (isNumberLogicElement(firstElement) && isNumberLogicElement(lastElement));
};

const getExprStartIndex = (firstElement) => {
    return (firstElement === "(") ? 1 : 0;
};

const parenthesisValidity = (logicExprArray, startIndex, lastIndex, parenthesis) => {
    let validity = true;

    for(let exprIndex=startIndex; exprIndex <= lastIndex; exprIndex++) {
        if(logicExprArray[exprIndex] === parenthesis) {
            validity = false;
            break;
        }
    }

    return validity;
};

const successiveRuleNumbersValidity = (logicExprArray, startIndex, lastIndex) => {
    let validity = true;
    let isPreviousElementNumber = isNumberLogicElement(logicExprArray[startIndex]);

    for(let exprIndex=startIndex + 1; exprIndex <= lastIndex; exprIndex++) {
        let isCurrentElementNumber = isNumberLogicElement(logicExprArray[exprIndex]);

        if(isPreviousElementNumber && isCurrentElementNumber) {
            validity = false;
            break;
        }
        isPreviousElementNumber = isCurrentElementNumber;
    }

    return validity;
};

const successiveAndOrValidity = (logicExprArray, startIndex, lastIndex) => {
    let hasOr = false;
    let hasAnd = false;

    for(let exprIndex=startIndex; exprIndex <= lastIndex; exprIndex++) {
        hasOr = hasOr || (logicExprArray[exprIndex] === "OR");
        hasAnd = hasAnd || (logicExprArray[exprIndex] === "AND");
    }
    return (hasOr && hasAnd) ? false : true;
};

export {validateRuleLogic, getRuleLogicArray};