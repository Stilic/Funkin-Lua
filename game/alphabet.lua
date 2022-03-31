local Alphabet = {}
Alphabet.__index = Alphabet

function string.indexOf(string, substring)
    return string.find(string, substring, 1, true)
end

local characters = {
    alphabet = "abcdefghijklmnopqrstuvwxyz",
    numbers = "1234567890",
    symbols = "|~#$%()*+-:;<=>@[]^_.,'!?"
}

local function new(text, bold, x, y)
    if text == nil then text = "cool swag" end
    if bold == nil then bold = false end
    if x == nil then x = 0 end
    if y == nil then y = 0 end

    local self = {
        x = x,
        y = y,

        sizeX = 1,
        sizeY = 1,

        text = text,
        isBold = bold,
        letters = {},
        lastLetter = nil,
        consecutiveSpaces = 0,

        destroyed = false
    }
    setmetatable(self, Alphabet)
    self:changeText(self.text)
    return self
end

function Alphabet:update(dt)
    if not self.destroyed then utils.callGroup(self.letters, "update", dt) end
end

function Alphabet:draw()
    if not self.destroyed then utils.callGroup(self.letters, "draw") end
end

function Alphabet:changeText(text)
    self:clear()

    self.text = text
    self.consecutiveSpaces = 0

    string.gsub(text, ".", function(c)
        local xPos = self.x

        local spaceChar = c == " " or (self.isBold and c == "_")
        if spaceChar then
            self.consecutiveSpaces = self.consecutiveSpaces + 1
        end

        local isNumber = string.indexOf(characters.numbers, c) ~= -1
        local isSymbol = string.indexOf(characters.symbols, c) ~= -1
        local isAlphabet =
            string.indexOf(characters.alphabet, string.lower(c)) ~= -1

        if (isAlphabet or isSymbol or isNumber) and
            (not self.isBold or not spaceChar) then
            if self.lastLetter ~= nil then
                xPos = xPos + lastLetter.x + lastLetter.width
            end
            if self.consecutiveSpaces > 0 then
                xPos = xPos + 40 * self.consecutiveSpaces
            end

            local letter = sprite(paths.atlas("alphabet"), xPos, self.y)

            local animName
            if self.isBold then
                if isNumber then
                    animName = "bold" .. c
                elseif isSymbol then
                    if c == "." then
                        animName = "PERIOD bold"
                    elseif c == "'" then
                        animName = "APOSTRAPHIE bold"
                    elseif c == "?" then
                        animName = "QUESTION MARK bold"
                    elseif c == "!" then
                        animName = "EXCLAMATION POINT bold"
                    else
                        animName = "bold " .. c
                    end

                    -- set position
                    if c == "'" then
                        self.y = self.y - 20
                    elseif c == "-" then
                        self.y = self.y + 20
                    elseif c == "(" then
                        self.x = self.x - 65
                        self.y = self.y - 5
                        letter.offsetX = 58
                    elseif c == ")" then
                        self.x = self.x - 20
                        self.y = self.y - 5
                        letter.offsetX = -12
                    elseif c == "." then
                        self.x = self.x + 45
                        self.y = self.y + 5
                        letter.offsetX = -3
                    end
                elseif isAlphabet then
                    animName = string.upper(c) .. " bold"
                end
            else
                if isNumber then
                    animName = c
                elseif isSymbol then
                    if c == "#" then
                        animName = "hashtag"
                    elseif c == "." then
                        animName = "period"
                    elseif c == "'" then
                        animName = "apostraphie"
                    elseif c == "?" then
                        animName = "question mark"
                    elseif c == "!" then
                        animName = "exclamation point"
                    elseif c == "," then
                        animName = "comma"
                    else
                        animName = letter
                    end

                    -- ima set position again
                    if c == "'" then
                        self.y = self.y - 70
                    elseif c == "-" then
                        self.y = self.y - 16
                    end
                elseif isAlphabet then
                    local case
                    if string.lower(c) ~= c then
                        case = "capital"
                    else
                        case = "lowercase"
                    end

                    animName = c .. " " .. case
                end
            end
            print(animName)

            letter:addByPrefix(c, animName)

            if not self.isBold and isAlphabet then
                self.y = self.y + 110 - letter.height
            end

            table.insert(self.letters, letter)
            self.lastLetter = letter

            letter:playAnim(c)
        end
    end)
end

function Alphabet:clear()
    if not self.destroyed then utils.callGroup(self.letters, "destroy") end
end

function Alphabet:destroy()
    if not self.destroyed then
        self:clear()
        self.destroyed = true
        collectgarbage()
    end

    return self
end

return
    setmetatable({new = new}, {__call = function(_, ...) return new(...) end})
