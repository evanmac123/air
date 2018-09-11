const spelledOutMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const DateMaker = {
  spelledOutMonths,
};

DateMaker.splitDate = rawDate => {
  const split = rawDate.split("T")[0].split("-");
  return {
    spelledOutMonth: spelledOutMonths[split[1] - 1],
    monthNumber: split[1],
    day: split[2],
    fullYear: split[0],
  };
};

export default DateMaker;
