const dropdownFields = [
  {
    label: "Condition",
    options: ["Used", "Damaged", "Salvage"],
  },
  {
    label: "Primary Damage",
    options: [
      "Front End",
      "Rear End",
      "Side",
      "Hail",
      "Mechanical",
    ],
  },
  {
    label: "Secondary Damage",
    options: [
      "Hail",
      "Water",
      "Minor Damage",
      "None",
    ],
  },
  {
    label: "Color",
    options: [
      "White",
      "Black",
      "Silver",
      "Blue",
      "Red",
    ],
  },
  {
    label: "Transmission",
    options: [
      "Automatic",
      "Manual",
    ],
  },
  {
    label: "Fuel",
    options: [
      "Gas",
      "Diesel",
      "Hybrid",
      "Electric",
    ],
  },
  {
    label: "Has Keys?",
    options: [
      "Yes",
      "No",
    ],
  },
];

function SelectField({
  label,
  options,
}: {
  label: string;
  options: string[];
}) {
  return (
    <div>
      <label className="mb-2 block text-sm font-semibold text-[#123f68]">
        {label}
      </label>

      <select className="h-11 w-full rounded-xl border border-[#dfe6ed] bg-white px-3 text-sm">
        <option>Select {label}</option>

        {options.map((item) => (
          <option key={item}>
            {item}
          </option>
        ))}
      </select>
    </div>
  );
}

export default function VehicleForm() {
  return (
    <div className="space-y-6">

      <div className="mb-8 flex items-start justify-between">

        <div>

          <div className="text-xs font-bold uppercase tracking-[0.18em] text-[#7a8da1]">
            Vehicles
            <span className="mx-2">›</span>
            Add Vehicle
          </div>

          <h1 className="mt-3 text-3xl font-black text-[#123f68]">
            Add Vehicle
          </h1>

          <p className="mt-2 text-sm text-[#7a8da1]">
            Enter vehicle details and upload media
          </p>

        </div>
      </div>


      <section className="rounded-2xl border border-[#dfe6ed] bg-white p-6">

        <h2 className="mb-5 text-lg font-black text-[#123f68]">
          Basic Information
        </h2>


        <div className="grid gap-5 md:grid-cols-4">

          {[
            "Make",
            "Model",
            "VIN (Chassis No.)",
            "Stock Number",
          ].map((field) => (
            <input
              key={field}
              placeholder={field}
              className="h-11 rounded-xl border border-[#dfe6ed] px-3 text-sm"
            />
          ))}


          <SelectField
            label="Year"
            options={[
              "2024",
              "2025",
              "2026",
            ]}
          />

          <SelectField
            label="Vehicle Type"
            options={[
              "SUV",
              "Sedan",
              "Truck",
            ]}
          />

        </div>

      </section>


      <section className="rounded-2xl border border-[#dfe6ed] bg-white p-6">

        <h2 className="mb-5 text-lg font-black text-[#123f68]">
          Vehicle Specifications
        </h2>


        <div className="grid gap-5 md:grid-cols-4">

          {dropdownFields.map((field) => (
            <SelectField
              key={field.label}
              {...field}
            />
          ))}

        </div>

      </section>


      <section className="rounded-2xl border border-[#dfe6ed] bg-white p-6">

        <h2 className="text-lg font-black text-[#123f68]">
          Media
        </h2>


        <p className="mt-2 text-sm text-[#7a8da1]">
          Upload up to 10 items (photos + 1 video)
        </p>


        <div className="mt-5 flex h-48 items-center justify-center rounded-xl border-2 border-dashed border-[#cbd6df]">

          <div className="text-center">

            <p className="font-bold text-[#123f68]">
              Drag & Drop files
            </p>

            <p className="text-sm text-[#7a8da1]">
              JPG, PNG, MP4
            </p>

          </div>

        </div>

      </section>


      <section className="rounded-2xl border border-[#dfe6ed] bg-white p-6">

        <h2 className="mb-5 text-lg font-black text-[#123f68]">
          Pricing
        </h2>

        <input
          placeholder="Price"
          className="h-11 rounded-xl border border-[#dfe6ed] px-3"
        />

      </section>


      <div className="flex justify-end gap-3 pb-4">

        <button
          className="rounded-xl border border-[#dfe6ed] bg-white px-6 py-3 text-sm font-bold text-[#123f68]"
        >
          Cancel
        </button>


        <button
          className="rounded-xl bg-[#123f68] px-6 py-3 text-sm font-bold text-white"
        >
          Save Vehicle
        </button>

      </div>

    </div>
  );
}
