"use client";

import { useState } from "react";
import { createVehicle } from "@/lib/api";

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
  value,
  onChange,
}: {
  label: string;
  options: string[];
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <div>
      <label className="mb-2 block text-sm font-semibold text-[#123f68]">
        {label}
      </label>

      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="h-11 w-full rounded-xl border border-[#dfe6ed] bg-white px-3 text-sm"
      >
        <option value="">Select {label}</option>

        {options.map((item) => (
          <option key={item} value={item}>
            {item}
          </option>
        ))}
      </select>
    </div>
  );
}

export default function VehicleForm() {

  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");

  const [vehicle, setVehicle] = useState({
    make: "",
    model: "",
    year: "",
    vehicleType: "",
    stockNumber: "",
    vin: "",
    lotNumber: "",
    auctionName: "",
    condition: "",
    primaryDamage: "",
    secondaryDamage: "",
    color: "",
    transmission: "",
    fuel: "",
    price: "",
    hasKeys: "",
  });

  async function handleSave() {
    if (!vehicle.make || !vehicle.model || !vehicle.year) {
      setMessage("Make, Model and Year are required.");
      return;
    }

    setSaving(true);
    setMessage("");

    try {
      const createdVehicle = await createVehicle({
        make: vehicle.make,
        model: vehicle.model,
        year: Number(vehicle.year),
        vehicleType: vehicle.vehicleType || undefined,
        stockNumber: undefined,
        vin: vehicle.vin || undefined,
        condition: vehicle.condition || undefined,
        primaryDamage: vehicle.primaryDamage || undefined,
        secondaryDamage: vehicle.secondaryDamage || undefined,
        color: vehicle.color || undefined,
        transmission: vehicle.transmission || undefined,
        fuel: vehicle.fuel || undefined,
        price: vehicle.price
          ? Number(vehicle.price)
          : undefined,
      });

      setMessage(
        `Vehicle created successfully. Stock Number: ${createdVehicle.stockNumber}`,
      );
    } catch {
      setMessage("Failed to create vehicle.");
    } finally {
      setSaving(false);
    }
  }

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
            "Stock Number",
            "VIN (Chassis No.)",
            "Auction Lot Number",
            "Auction Name",
          ].map((field) => (
            <input
              key={field}
              placeholder={field}
              value={
                vehicle[
                  field === "Make"
                    ? "make"
                    : field === "Model"
                    ? "model"
                    : field === "VIN (Chassis No.)"
                    ? "vin"
                    : field === "Stock Number"
                    ? "stockNumber"
                    : field === "Auction Lot Number"
                    ? "lotNumber"
                    : "auctionName"
                ]
              }
              onChange={(event) =>
                setVehicle({
                  ...vehicle,
                  [field === "Make"
                    ? "make"
                    : field === "Model"
                    ? "model"
                    : field === "VIN (Chassis No.)"
                    ? "vin"
                    : field === "Stock Number"
                    ? "stockNumber"
                    : field === "Auction Lot Number"
                    ? "lotNumber"
                    : "auctionName"]: event.target.value,
                })
              }
              className="h-11 rounded-xl border border-[#dfe6ed] px-3 text-sm"
            />
          ))}


          <SelectField
            label="Year"
            value={vehicle.year}
            onChange={(value) =>
              setVehicle({ ...vehicle, year: value })
            }
            options={Array.from(
              { length: new Date().getFullYear() - 1990 + 1 },
              (_, index) => String(new Date().getFullYear() - index),
            )}
          />

          <SelectField
            label="Vehicle Type"
            value={vehicle.vehicleType}
            onChange={(value) =>
              setVehicle({ ...vehicle, vehicleType: value })
            }
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

          {dropdownFields.map((field) => {
            const stateKey =
              field.label === "Condition"
                ? "condition"
                : field.label === "Primary Damage"
                ? "primaryDamage"
                : field.label === "Secondary Damage"
                ? "secondaryDamage"
                : field.label === "Color"
                ? "color"
                : field.label === "Transmission"
                ? "transmission"
                : field.label === "Fuel"
                ? "fuel"
                : "hasKeys";

            return (
              <SelectField
                key={field.label}
                label={field.label}
                options={field.options}
                value={vehicle[stateKey]}
                onChange={(value) =>
                  setVehicle({ ...vehicle, [stateKey]: value })
                }
              />
            );
          })}

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
          type="number"
          min="0"
          step="0.01"
          placeholder="Price"
          value={vehicle.price}
          onChange={(event) =>
            setVehicle({ ...vehicle, price: event.target.value })
          }
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
          type="button"
          onClick={handleSave}
          disabled={saving}
          className="rounded-xl bg-[#123f68] px-6 py-3 text-sm font-bold text-white disabled:cursor-not-allowed disabled:opacity-60"
        >
          {saving ? "Saving..." : "Save Vehicle"}
        </button>

      </div>

      {message && (
        <div className="rounded-xl border border-[#dfe6ed] bg-white px-4 py-3 text-sm font-semibold text-[#123f68]">
          {message}
        </div>
      )}

    </div>
  );
}
