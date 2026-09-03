export default function Header() {
  return (
    <header className="h-20 border-b border-[#dfe6ed] bg-white px-6 md:px-8">
      <div className="flex h-full items-center justify-between">

        <div>
          <p className="text-xs font-bold uppercase tracking-[0.18em] text-[#7a8da1]">
            King Auto Operations
          </p>

          <h2 className="mt-1 text-xl font-black text-[#123f68]">
            Admin Portal
          </h2>
        </div>


        <div className="flex items-center gap-3">

          <input
            className="hidden h-10 w-64 rounded-xl border border-[#dfe6ed] bg-[#f8fafc] px-4 text-sm outline-none md:block"
            placeholder="Search admin..."
          />


          <button
            className="h-10 rounded-xl border border-[#dfe6ed] bg-white px-5 text-sm font-bold text-[#123f68]"
          >
            Admin
          </button>

        </div>

      </div>
    </header>
  );
}
