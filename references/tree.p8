pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
root = {}
root.attac = "a"
root.left = {}
root.left.attac = "aa"
root.right = {}
root.right.attac = "ab"
root.left.left = {}
root.left.left.attac = "aaa"
root.left.right = {}
root.left.right.attac = "aab"
root.right.left = {}
root.right.left.attac = "aba"
root.right.right = {}
root.right.right.attac = "abb"
curr = root

function _update()
	if btnp(4) then
	if #curr.attac == 3 then
		curr = root
	else
		curr = curr.left end
	end
	
	if btnp(5) then
	if #curr.attac == 3 then
		curr = root
	else
		curr = curr.right end
	end
	
	
end

function _draw()
	cls()
	print(curr.attac)

end
