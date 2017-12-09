function enclosingSelect(target) {
  /* Some clients treat the option tag as the target of this, others the 
   select tag--which is exactly the kind of nonsense jQuery is supposed to 
   gloss over. */
  return $(target).closest('select').first();
}
