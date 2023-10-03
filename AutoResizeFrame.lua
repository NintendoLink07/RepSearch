local addonName, repSearch = ...

ResizableFrameMixin = {}

function ResizableFrameMixin:AddChild(child, pointTable)
    local width, height = child:GetSize()
    local point, anchor, relativePoint, offX, offY = unpack(pointTable)

    if(child:IsVisible()) then
        if(string.find(point, "LEFT")) then
            if(self:GetWidth() < offX + width) then
                self:SetWidth(offX + width)
            end
        end

        if(string.find(point, "TOP")) then
            if(self:GetHeight() < offY + height) then
                self:SetHeight(offY + height)
            end
        end
    end

    child:SetPoint(point, anchor, relativePoint, offX, offY)
end