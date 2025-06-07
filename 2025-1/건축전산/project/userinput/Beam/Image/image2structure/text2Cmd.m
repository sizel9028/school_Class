function text2Cmd(rawText)


    global Queue


    commands = cleanText(rawText);

    Queue = commands;
end
