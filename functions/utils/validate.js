
const isValidString = (val) => typeof val === 'string' && val.trim() !== '';

module.exports = { isValidString };