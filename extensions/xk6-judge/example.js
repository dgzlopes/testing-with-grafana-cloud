import judge from 'k6/x/judge';

export default function () {
  console.log(judge.score("Pepperoni"));
}
