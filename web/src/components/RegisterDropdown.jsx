import { Link } from "react-router-dom";
import { registerOptions, ChevronRight } from "../data/registerOptions.jsx";

export default function RegisterDropdown({ id }) {
  return (
    <div
      id={id}
      className="register-menu-enter absolute right-0 top-[calc(100%+0.75rem)] z-50 w-[calc(100vw-2rem)] max-w-[25rem] overflow-hidden rounded-[1.7rem] bg-white p-3 text-ink shadow-menu ring-1 ring-black/5 sm:w-[25rem]"
    >
      <div className="grid gap-1">
        {registerOptions.map(({ title, description, path, Icon }) => (
          <Link
            to={path}
            key={title}
            className="focus-ring group grid grid-cols-[2.25rem_1fr_auto] items-center gap-3 rounded-2xl px-3 py-4 transition hover:bg-paper"
          >
            <span className="grid size-9 place-items-center text-josi-red">
              <Icon size={23} strokeWidth={2.5} />
            </span>
            <span className="min-w-0">
              <span className="block text-[1rem] font-bold leading-tight text-ink">
                {title}
              </span>
              <span className="mt-1 block text-[0.8rem] font-medium leading-snug text-muted">
                {description}
              </span>
            </span>
            <ChevronRight
              size={24}
              className="text-ink transition group-hover:translate-x-1"
              strokeWidth={2.2}
            />
          </Link>
        ))}
      </div>
    </div>
  );
}
