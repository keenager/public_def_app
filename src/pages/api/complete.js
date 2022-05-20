export default function Complete(req, res){
    res.writeHead(200, { "Content-Type": "text/html;charset=utf-8" });
    res.write(`<h3>완료!!!</h3>`);
    res.end();
}