# Installation

Installation of nbl-target documentation.

---

## 1. Download the nbl-target Asset

To begin, download the **nbl-target** asset from your FiveM keymaster panel. Simply go to your **granted assets page** and install the resource from there.

Access the download here: [https://portal.cfx.re/assets/granted-assets](https://portal.cfx.re/assets/granted-assets)

---

## 2. Drag & Drop the Resources

Place the **nbl-target** folder into your server's **resources** directory. Ensure that the folder name **remains unchanged** to guarantee proper loading and full compatibility.

---

## 3. Start the Resource

Open your **server.cfg** file and add the **nbl-target** resource:

```cfg
ensure nbl-target
```

---

## 4. Configuration

The resource comes with a default configuration file located at `config/config.lua`. You can customize:

- **Controls**: Activation key and select button
- **Targeting**: Maximum distance, raycast flags, default interaction distance
- **Visual**: Outline colors, marker settings
- **Menu**: Scale, animations, refresh intervals

No additional setup is required. The resource is ready to use after installation!

---

## 5. Restart Your Server

After adding the resource to your `server.cfg`, restart your server to load **nbl-target**.

---

## Next Steps

Once installed, you can start using the exports to register options for entities. Check the [Exports documentation](./exports/) for detailed information on how to use each export function.

