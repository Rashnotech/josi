import { CircleDot, Clock3, LocateFixed, MapPin } from "lucide-react";
import Button from "./Button.jsx";

export default function SearchPanel() {
  return (
    <div className="w-full max-w-md">
      <div className="mb-4 inline-flex items-center gap-2 rounded-full bg-paper px-3 py-2 text-sm font-bold">
        <Clock3 size={16} />
        Pickup now
      </div>

      <form className="grid gap-3" aria-label="Book a Josi ride">
        <label className="relative block">
          <span className="sr-only">Pickup location</span>
          <CircleDot
            size={18}
            className="absolute left-4 top-1/2 -translate-y-1/2 text-ink"
          />
          <input
            className="focus-ring h-12 w-full rounded-lg border-0 bg-paper pl-12 pr-12 text-sm font-semibold text-ink placeholder:text-muted"
            placeholder="Pickup location"
          />
          <LocateFixed
            size={18}
            className="absolute right-4 top-1/2 -translate-y-1/2 text-muted"
          />
        </label>

        <label className="relative block">
          <span className="sr-only">Destination</span>
          <MapPin
            size={18}
            className="absolute left-4 top-1/2 -translate-y-1/2 text-ink"
          />
          <input
            className="focus-ring h-12 w-full rounded-lg border-0 bg-paper pl-12 pr-12 text-sm font-semibold text-ink placeholder:text-muted"
            placeholder="Where to?"
          />
          <LocateFixed
            size={18}
            className="absolute right-4 top-1/2 -translate-y-1/2 text-muted"
          />
        </label>

        <div className="flex flex-wrap items-center gap-4 pt-1">
          <Button type="submit">See prices</Button>
          <a
            className="focus-ring rounded-lg py-3 text-sm font-bold text-muted hover:text-ink"
            href="#account"
          >
            Log in to see your recent activity
          </a>
        </div>
      </form>
    </div>
  );
}
