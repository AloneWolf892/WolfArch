move_node_desktop_next() {
  id = bspc query --nodes --node
  bspc node --to-desktop next
  bspc desktop --focus next
  bspc node --focus $id
}

move_node_desktop_prev() {
  id = bspc query --nodes --node
  bspc node --to-desktop prev 
  bspc desktop --focus prev 
  bspc node --focus $id
}
