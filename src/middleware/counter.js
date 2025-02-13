const addCounter = async (req, res, next) => {
  try {
    await fetch(
      "https://vercel.com/kmrcellnets-projects/web/D9ttPExij34HX6j1kwHVNeF3QmYn"
    );
    next();
  } catch (error) {
    console.log(error);
  }
};

export default addCounter;
