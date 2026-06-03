import logoUrl from "../assets/josi-logo.jpeg";

function RoadLine() {
  return <span className="h-1 w-10 rounded-full bg-white/70" />;
}

export function HeroCarArt() {
  return (
    <div className="relative min-h-[16rem] overflow-hidden rounded-lg bg-[#f4b33d] p-5 sm:min-h-[21rem]">
      <div className="absolute inset-y-0 left-[25%] w-[12%] bg-josi-black" />
      <div className="absolute right-0 top-0 h-full w-[72%] bg-josi-darkRed">
        <div className="absolute inset-0 bg-[linear-gradient(135deg,transparent_0_45%,rgba(255,255,255,0.08)_45%_68%,transparent_68%)]" />
      </div>
      <div className="absolute bottom-6 left-1/2 w-[78%] -translate-x-1/2 rounded-lg bg-white/95 p-3 shadow-soft">
        <div className="rounded-t-[2rem] bg-[#141414] p-4">
          <div className="mx-auto h-20 w-[86%] rounded-t-[2rem] bg-[#46a8e8]">
            <div className="grid h-full grid-cols-3 gap-2 p-3">
              <div className="rounded bg-[#1d62a2]" />
              <div className="rounded bg-[#eec84c]" />
              <div className="rounded bg-[#1d62a2]" />
            </div>
          </div>
          <div className="mx-auto mt-3 flex w-[82%] items-center justify-between">
            <span className="size-10 rounded-full border-[10px] border-[#222] bg-[#848484]" />
            <span className="size-10 rounded-full border-[10px] border-[#222] bg-[#848484]" />
          </div>
        </div>
        <div className="flex items-center justify-between rounded-b-lg bg-[#d7d7d7] px-3 py-2 text-xs font-bold">
          <span>Ready to travel?</span>
          <span className="rounded-full bg-white px-3 py-1">Schedule ahead</span>
        </div>
      </div>
    </div>
  );
}

export function ServiceMiniArt({ type }) {
  if (type === "reserve") {
    return (
      <div className="relative h-16 w-24">
        <div className="absolute right-1 top-2 h-10 w-12 rounded-lg bg-white shadow-soft">
          <div className="h-3 rounded-t-lg bg-josi-red" />
          <div className="p-1">
            <div className="mb-1 h-1 rounded bg-line" />
            <div className="h-1 w-7 rounded bg-line" />
          </div>
        </div>
        <div className="absolute bottom-1 left-4 size-12 rounded-full border-4 border-ink bg-white">
          <span className="absolute left-1/2 top-2 h-4 w-0.5 -translate-x-1/2 bg-ink" />
          <span className="absolute left-1/2 top-1/2 h-0.5 w-4 bg-ink" />
        </div>
      </div>
    );
  }

  if (type === "courier") {
    return (
      <div className="relative h-16 w-24">
        <span className="absolute right-6 top-3 size-5 rounded-full bg-[#f7c86b]" />
        <span className="absolute right-8 top-8 h-7 w-4 rounded-full bg-josi-red" />
        <span className="absolute bottom-2 left-5 h-2 w-14 rounded-full bg-ink" />
        <span className="absolute bottom-2 left-8 size-4 rounded-full border-4 border-ink bg-white" />
        <span className="absolute bottom-2 right-4 size-4 rounded-full border-4 border-ink bg-white" />
      </div>
    );
  }

  return (
    <div className="relative h-16 w-24">
      <div className="absolute bottom-3 left-2 h-8 w-[4.5rem] rounded-t-2xl bg-white shadow-soft vehicle-shadow">
        <span className="absolute left-3 top-2 h-3 w-8 rounded-t-lg bg-[#b8d8ef]" />
        <span className="absolute bottom-[-0.4rem] left-3 size-4 rounded-full bg-ink" />
        <span className="absolute bottom-[-0.4rem] right-3 size-4 rounded-full bg-ink" />
      </div>
      <span className="absolute right-2 top-2 h-7 w-7 rounded bg-josi-red" />
    </div>
  );
}

export function AccountArt() {
  return (
    <div className="relative min-h-[15rem] overflow-hidden rounded-lg bg-paper">
      <div className="absolute bottom-0 left-[18%] h-28 w-24 rounded-t-full bg-[#2468d8]" />
      <div className="absolute bottom-24 left-[27%] size-16 rounded-full bg-[#f2b58d]" />
      <div className="absolute bottom-28 left-[22%] h-20 w-24 rounded-t-full bg-ink" />
      <div className="absolute bottom-32 left-[31%] h-3 w-8 rounded-full bg-ink" />
      <div className="absolute bottom-0 right-[18%] h-32 w-28 rounded-t-full bg-ink" />
      <div className="absolute bottom-28 right-[27%] size-16 rounded-full bg-[#d69d82]" />
      <div className="absolute bottom-36 right-[29%] h-3 w-10 rounded-full bg-white/70" />
      <div className="absolute bottom-7 right-[18%] h-16 w-36 rounded-t-full border-[1.1rem] border-white" />
    </div>
  );
}

export function ReserveArt() {
  return (
    <div className="relative min-h-[19rem] overflow-hidden rounded-lg bg-[#a9dce6] p-5">
      <div className="max-w-[15rem]">
        <h3 className="text-2xl font-extrabold leading-tight">
          Get your ride right with Josi Reserve
        </h3>
        <p className="mt-5 text-xs font-bold">Choose date and time</p>
        <div className="mt-3 grid grid-cols-2 gap-3">
          <div className="rounded-lg bg-white px-3 py-3 text-xs font-bold">Date</div>
          <div className="rounded-lg bg-white px-3 py-3 text-xs font-bold">Time</div>
        </div>
        <div className="mt-4 rounded-lg bg-ink px-4 py-3 text-center text-sm font-bold text-white">
          Next
        </div>
      </div>
      <div className="absolute -right-8 bottom-4 h-56 w-36 rotate-[-22deg] rounded-[2rem] bg-white/70 shadow-soft">
        <div className="mx-auto mt-5 h-32 w-10 rounded-full bg-[#935337]" />
        <div className="absolute bottom-6 left-1/2 size-24 -translate-x-1/2 rounded-full border-[12px] border-ink bg-white">
          <span className="absolute left-1/2 top-3 h-7 w-1 -translate-x-1/2 rounded bg-ink" />
          <span className="absolute left-1/2 top-1/2 h-1 w-8 rounded bg-ink" />
        </div>
      </div>
    </div>
  );
}

export function CityArt() {
  return (
    <div className="relative min-h-[17rem] overflow-hidden rounded-lg bg-[#49a6f3]">
      <div className="absolute inset-x-0 top-0 h-24 bg-[linear-gradient(#0b70db,#ffcd61)]" />
      <div className="absolute left-8 top-12 h-1.5 w-20 rotate-[-12deg] rounded-full bg-white">
        <span className="absolute right-[-1rem] top-[-0.45rem] h-4 w-7 rounded-r-full bg-[#f8d247]" />
      </div>
      <div className="absolute bottom-0 left-0 h-28 w-full bg-[#6fbf5b]" />
      <div className="absolute bottom-10 left-6 h-28 w-10 bg-white" />
      <div className="absolute bottom-10 left-20 h-40 w-12 bg-[#f6d34c]" />
      <div className="absolute bottom-10 left-36 h-32 w-14 bg-white" />
      <div className="absolute bottom-10 right-16 h-36 w-12 bg-[#f6d34c]" />
      <div className="absolute bottom-10 right-6 h-24 w-12 bg-white" />
      <div className="absolute bottom-0 left-0 right-0 flex justify-center gap-2 pb-5">
        <RoadLine />
        <RoadLine />
        <RoadLine />
      </div>
    </div>
  );
}

export function DriverCabinArt() {
  return (
    <div className="relative min-h-[20rem] overflow-hidden rounded-lg bg-[#dd7d50]">
      <div className="absolute inset-x-0 top-0 h-24 bg-[#f3a065]" />
      <div className="absolute left-8 top-14 h-20 w-28 rounded-t-lg bg-[#281611]" />
      <div className="absolute left-12 top-20 h-10 w-16 rounded bg-[#ffd29f]" />
      <div className="absolute bottom-0 left-0 h-36 w-36 bg-[#1b1b1b]" />
      <span className="absolute bottom-32 left-16 size-16 rounded-full bg-[#1b1b1b]" />
      <span className="absolute bottom-24 left-28 h-16 w-28 rotate-12 rounded-full bg-[#1b1b1b]" />
      <span className="absolute bottom-5 right-10 h-24 w-36 rounded-t-full border-[1.2rem] border-[#1b1b1b]" />
      <span className="absolute bottom-0 right-0 h-28 w-28 rounded-tl-[3rem] bg-[#32231d]" />
    </div>
  );
}

export function BusinessArt() {
  return (
    <div className="relative min-h-[19rem] overflow-hidden rounded-lg bg-[#91d3fb]">
      <div className="absolute left-0 top-0 h-full w-[46%] skew-x-[-11deg] bg-[#d8f0ff]" />
      <div className="absolute left-11 top-0 h-full w-1 bg-[#4aa0db]" />
      <div className="absolute left-24 top-0 h-full w-1 bg-[#4aa0db]" />
      <div className="absolute right-0 top-0 h-full w-[38%] bg-[#ffd15f]" />
      <div className="absolute bottom-6 right-8 h-12 w-28 rounded-t-2xl bg-white shadow-soft">
        <span className="absolute bottom-[-0.35rem] left-4 size-4 rounded-full bg-ink" />
        <span className="absolute bottom-[-0.35rem] right-4 size-4 rounded-full bg-ink" />
      </div>
      <div className="absolute left-8 top-8 h-1.5 w-20 rotate-[-12deg] rounded-full bg-white">
        <span className="absolute right-[-1rem] top-[-0.45rem] h-4 w-7 rounded-r-full bg-[#f8d247]" />
      </div>
    </div>
  );
}

export function RentalArt() {
  return (
    <div className="relative min-h-[20rem] overflow-hidden rounded-lg bg-[#178bec]">
      <div className="absolute inset-x-0 top-0 h-24 bg-[linear-gradient(#1e88ee,#ffe06a)]" />
      <div className="absolute bottom-0 h-20 w-full bg-[#f0d873]" />
      <div className="absolute bottom-14 left-8 h-16 w-44 rounded-t-[2rem] bg-white shadow-soft">
        <span className="absolute left-10 top-4 h-5 w-16 rounded bg-[#bfe2f9]" />
        <span className="absolute bottom-[-0.45rem] left-8 size-5 rounded-full bg-ink" />
        <span className="absolute bottom-[-0.45rem] right-8 size-5 rounded-full bg-ink" />
      </div>
      <span className="absolute bottom-28 right-28 size-12 rounded-full bg-[#724026]" />
      <span className="absolute bottom-[4.5rem] right-24 h-24 w-10 rounded-full bg-[#266fd7]" />
      <span className="absolute bottom-16 right-14 h-10 w-20 rotate-[-20deg] rounded-full bg-ink" />
      <img
        src={logoUrl}
        alt=""
        className="absolute right-5 top-5 h-12 w-16 rounded object-cover opacity-90"
      />
    </div>
  );
}
