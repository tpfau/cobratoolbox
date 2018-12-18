function resultString = regexprepfun(string, expression, replacement)
% Replace the given expression in the string by the information in replacement. 
% USAGE:
%    string = regexprepfun(string, expression, replacement)
%
% INPUTS:
%    string:         The target string in which to replace parts
%    expression:     The expression to replace
%    replacement:    The replacement for the expression. Can contain groups 
%                    identified in the original string, and can make use of functions.
%
% OUTPUT:
%    resultString:         The string with the replaced data.

if iscell(string)
  stringCell = string;
  resultString = cell(size(stringCell));
  for c = 1:numel(stringCell)
    string = stringCell{c};
    [toks,firsts,lasts] = regexp(string,expression,'tokens');
    if numel(toks) == 0
      resultString = string;
      return
    endif
    tokenMatches = arrayfun(@(x,y) string(x:y),firsts,lasts,'Uniform',false);
    % determine which part of the replacement might be a function call. We do not 
    % allow nested function calls

    [repfunctions,repstarts,repends] = getFunctionsInString(replacement);
    funsToReplace = arrayfun(@(x,y) replacement(x:y),repstarts,repends,'Uniform',false);
    % select the first token (we only have the one)
    tokenreplace = cell(numel(toks));
    for i = 1:numel(toks)
        % now replace all found entries    
        creplacement = replacement;
        for j = 1:numel(repfunctions)
            crepfunction = replaceTokens(repfunctions{j},toks{i});
            creplacement = strrep(creplacement,funsToReplace{j},evalin('caller',crepfunction));               
        endfor
        tokenreplace{i} = creplacement;
    endfor
  
    cresultString = '';
    cpos = 1;
    for i = 1:numel(toks)
      cresultString = [cresultString, string(cpos:firsts(i)-1), tokenreplace{i}]; 
      cpos = lasts(i)+1;
    endfor
    cresultString = [cresultString,string(cpos:end)];
    resultString{c} = cresultString;
  end  
else
  [toks,firsts,lasts] = regexp(string,expression,'tokens');
  if numel(toks) == 0
    resultString = string;
    return
  endif
  tokenMatches = arrayfun(@(x,y) string(x:y),firsts,lasts,'Uniform',false);
  % determine which part of the replacement might be a function call. We do not 
  % allow nested function calls

  [repfunctions,repstarts,repends] = getFunctionsInString(replacement);
  funsToReplace = arrayfun(@(x,y) replacement(x:y),repstarts,repends,'Uniform',false);
  % select the first token (we only have the one)
  tokenreplace = cell(numel(toks));
  for i = 1:numel(toks)
      % now replace all found entries    
      creplacement = replacement;
      for j = 1:numel(repfunctions)
          crepfunction = replaceTokens(repfunctions{j},toks{i});
          creplacement = strrep(creplacement,funsToReplace{j},evalin('caller',crepfunction));               
      endfor
      tokenreplace{i} = creplacement;
  endfor

  resultString = '';
  cpos = 1;
  for i = 1:numel(toks)
    resultString = [resultString, string(cpos:firsts(i)-1), tokenreplace{i}]; 
    cpos = lasts(i)+1;
  endfor
  resultString = [resultString,string(cpos:end)];
end
endfunction


function string = replaceTokens(string, tokens)
    for i = numel(tokens):-1:1
      % more than one matching token is not allowed, otherwise this is problematic.'
      string = strrep(string,['$' num2str(i)],tokens{i});
    endfor      
endfunction


function [funStrings,funStarts,funEnds] = getFunctionsInString(stringToExtract)
    openingCount = 0;
    closingCount = 0;
    funStarts = [];
    funEnds = [];
    funStrings = {};
    cStarts = strfind(stringToExtract,'${');  
    openpos = strfind(stringToExtract,'{');
    closePos = strfind(stringToExtract,'}');

    for i = 1:numel(cStarts)
        cpos = cStarts(i)+1;
        openingCount = 1;
        closingCount = 0;
        while openingCount > closingCount && cpos < length(stringToExtract)
            cpos = cpos + 1;
            if stringToExtract(cpos) == '}'
              closingCount = closingCount +1;
            endif
            if stringToExtract(cpos) == '{'
              openingCount = openingCount +1;
            endif
        endwhile
        if openingCount == closingCount
          funStrings{end+1} = stringToExtract(cStarts(i)+2:cpos-1);
          funStarts(end+1) = cStarts(i);
          funEnds(end+1) = cpos;
        endif
        
    endfor
    
endfunction
