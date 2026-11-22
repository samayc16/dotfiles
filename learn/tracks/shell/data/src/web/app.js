// TODO: debounce search input
export function search(q) {
  // FIXME: no error handling
  return fetch(`/api/search?q=${q}`);
}
// FIXME: remove before launch
console.log("debug");
