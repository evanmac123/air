const MapWithIndex = (arr, cb) => {
  const result = [];
  for (let i = 0; i < arr.length; i++) {
    result.push(cb(arr[i], i));
  }
  return result;
};

export default MapWithIndex;
