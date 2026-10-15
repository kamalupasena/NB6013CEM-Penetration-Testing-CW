import assert from 'node:assert/strict';
const v=`http://127.0.0.1:${process.env.VEHICLE_PORT||8081}/api`,b=`http://127.0.0.1:${process.env.BANK_PORT||8082}/api`;
async function call(base,path,method='GET',body,cookie=''){const r=await fetch(base+path,{method,headers:{...(body?{'content-type':'application/json'}:{}),...(cookie?{cookie}:{})},body:body?JSON.stringify(body):undefined});let out;try{out=await r.json()}catch{out={}}return {status:r.status,body:out,cookie:r.headers.get('set-cookie')?.split(';')[0]||''}}
const vh=await call(v,'/health'),bh=await call(b,'/health');assert.equal(vh.status,200);assert.equal(bh.status,200);
const vl=await call(v,'/auth/login','POST',{email:'maya@vehicle.test',password:'Welcome123!'}),bl=await call(b,'/auth/login','POST',{email:'elena@securebank.test',password:'Welcome123!'});assert.equal(vl.status,200);assert.equal(bl.status,200);assert.ok(vl.cookie);assert.ok(bl.cookie);
const vc=vl.cookie,bc=bl.cookie;
const vehicles=await call(v,'/vehicles','GET',undefined,vc);assert.equal(vehicles.status,200);assert.ok(vehicles.body.items.length>=2);
const doc=await call(v,`/vehicles/${vehicles.body.items[0].id}/documents`,'GET',undefined,vc);assert.equal(doc.status,200);
const bookings=await call(v,'/bookings','GET',undefined,vc);assert.equal(bookings.status,200);
const accounts=await call(b,'/accounts','GET',undefined,bc);assert.equal(accounts.status,200);assert.ok(accounts.body.items.length>=2);
const own=await call(b,`/accounts/${accounts.body.items[0].id}`,'GET',undefined,bc);assert.equal(own.status,200);
const tx=await call(b,'/transactions','GET',undefined,bc);assert.equal(tx.status,200);
if(process.argv.includes('--seed-only')){assert.equal(vehicles.body.items.length,2);assert.equal(bookings.body.items.length,1);assert.equal(Number(accounts.body.items.find(x=>x.number==='SB100001')?.balance_cents),250000);assert.equal(Number(accounts.body.items.find(x=>x.number==='SB100002')?.balance_cents),850000);console.log('Deterministic seed data present');process.exit(0)}
const suffix=Date.now().toString(36);const vr=await call(v,'/auth/register','POST',{name:'Test Customer',email:`test-${suffix}@vehicle.test`,password:'Testing123!'});assert.equal(vr.status,201);
const br=await call(b,'/auth/register','POST',{name:'Test Customer',email:`test-${suffix}@securebank.test`,password:'Testing123!'});assert.equal(br.status,201);
const newV=await call(v,'/vehicles','POST',{registration:`TST-${suffix.slice(-4)}`,make:'Toyota',model:'Yaris',year:2021,notes:'Daily commuter'},vc);assert.equal(newV.status,201);
const updateV=await call(v,`/vehicles/${newV.body.id}`,'PATCH',{registration:newV.body.registration,make:'Toyota',model:'Yaris',year:2021,notes:'Recently serviced'},vc);assert.equal(updateV.status,200);
const newDoc=await call(v,`/vehicles/${newV.body.id}/documents`,'POST',{title:'Service note',body:'Synthetic inspection record'},vc);assert.equal(newDoc.status,201);
const newBooking=await call(v,'/bookings','POST',{vehicleId:newV.body.id,serviceType:'Diagnostics',appointment:'2026-12-04T10:30'},vc);assert.equal(newBooking.status,201);
const other=await call(b,'/accounts','GET',undefined,(await call(b,'/auth/login','POST',{email:'marcus@securebank.test',password:'Welcome123!'})).cookie);const transfer=await call(b,'/transfers','POST',{fromAccountId:accounts.body.items[0].id,toAccountNumber:other.body.items[0].number,amountCents:100,memo:'Smoke test'},bc);assert.equal(transfer.status,201);
const denied=await call(v,'/staff/overview','GET',undefined,vc);assert.equal(denied.status,403);
const deniedBank=await call(b,'/operations/support/1','PATCH',{response:'test'},bc);assert.equal(deniedBank.status,403);
console.log('Integration workflows passed');
