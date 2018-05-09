pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
node = {}
node.attac=" "
root = {}
node.left = root

right = {}
right.attac = "b"
node.right = right

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
root.left.left.left = {}
root.left.left.left.attac="aaaa"
root.left.left.right = {}
root.left.left.right.attac="aaab"
root.left.right.left = {}
root.left.right.left.attac="aaba"
root.left.right.right = {}
root.left.right.right.attac="aabb"
root.right.left.left = {}
root.right.left.left.attac="abaa"
root.right.left.right = {}
root.right.left.right.attac="abab"
root.right.right.left = {}
root.right.right.left.attac="abba"
root.right.right.right = {}
root.right.right.right.attac="abbb"


right.left = {}
right.left.attac = "ba"
right.right = {}
right.right.attac = "bb"
right.left.left = {}
right.left.left.attac = "baa"
right.left.right = {}
right.left.right.attac = "bab"
right.right.left = {}
right.right.left.attac = "bba"
right.right.right = {}
right.right.right.attac = "bbb"
right.left.left.left = {}
right.left.left.left.attac="baaa"
right.left.left.right = {}
right.left.left.right.attac="baab"
right.left.right.left = {}
right.left.right.left.attac="baba"
right.left.right.right = {}
right.left.right.right.attac="babb"
right.right.left.left = {}
right.right.left.left.attac="bbaa"
right.right.left.right = {}
right.right.left.right.attac="bbab"
right.right.right.left = {}
right.right.right.left.attac="bbba"
right.right.right.right = {}
right.right.right.right.attac="bbbb"
curr = node

function _update()
	if btnp(4) then
	if #curr.attac == 4 then
		curr = node
	else
		curr = curr.left end
	end
	
	if btnp(5) then
	if #curr.attac == 4 then
		curr = node
	else
		curr = curr.right end
	end
	
	
end

function _draw()
	cls()
	print(curr.attac)

end
