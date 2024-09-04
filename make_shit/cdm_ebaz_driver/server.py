from typing import Union

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from time import sleep, time

from cdm_driver import CdmDriver

app = FastAPI()
cdm = CdmDriver()

class RunRequest(BaseModel):
    image: list[int]

class RunResponse(BaseModel):
    memory: list[int]
    registers: dict[str, int]
    ticks: int = 1337


@app.post("/run")
async def run_image(req: RunRequest) -> RunResponse:
    # I should probably synchronize this
    cdm.set_reset(True)
    cdm.load_ram(req.image)
    cdm.set_reset(False)
    start_time = time()
    while cdm.get_status() == 0:
        if time() - start_time > 1:
            raise HTTPException(status_code=418, detail="Timeout")
    regs = dict(zip(["r0","r1","r2","r3","r4","r5","r6","fp","sp","pc","ps"], cdm.get_regs()))
    regs['r7'] = regs['fp']
    return RunResponse(
        memory=list(cdm.get_ram()),
        registers=regs,
    )

