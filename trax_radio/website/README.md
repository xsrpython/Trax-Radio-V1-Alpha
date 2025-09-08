# 🌐 Trax Radio UK Website Setup Guide

## **Quick Setup Options**

### **Option 1: GitHub Pages (RECOMMENDED - FREE)**

1. **Create GitHub Repository**
   - Go to [GitHub.com](https://github.com)
   - Click "New Repository"
   - Name: `trax-radio-website`
   - Make it public
   - Initialize with README

2. **Upload Website Files**
   - Upload all files from `website/` folder
   - Keep the folder structure intact

3. **Enable GitHub Pages**
   - Go to repository Settings
   - Scroll to "Pages" section
   - Source: "Deploy from a branch"
   - Branch: "main"
   - Folder: "/ (root)"
   - Click "Save"

4. **Your Website URL**
   - `https://[your-username].github.io/trax-radio-website`

### **Option 2: Netlify (FREE & EASY)**

1. **Go to [Netlify.com](https://netlify.com)**
2. **Sign up with GitHub**
3. **Click "New site from Git"**
4. **Connect your GitHub repository**
5. **Deploy automatically**
6. **Custom domain available**

### **Option 3: Vercel (FREE & FAST)**

1. **Go to [Vercel.com](https://vercel.com)**
2. **Sign up with GitHub**
3. **Import your repository**
4. **Deploy with one click**
5. **Automatic HTTPS**

---

## **File Structure**

```
website/
├── index.html              # Main homepage
├── privacy-policy.html     # Privacy policy page
├── styles.css             # All CSS styles
├── script.js              # JavaScript functionality
├── assets/                # Images and icons
│   ├── traxicon.png       # App icon (512x512)
│   ├── phone-mockup.png   # Phone mockup image
│   └── app-screenshot.png # App screenshot
└── releases/              # APK files
    └── trax-radio-uk-v1.0.0.apk
```

---

## **Required Images to Create**

### **1. Phone Mockup (phone-mockup.png)**
- **Size**: 300x600 pixels
- **Content**: Phone showing Trax Radio app
- **Style**: Modern phone frame with app screenshot

### **2. App Screenshot (app-screenshot.png)**
- **Size**: 300x600 pixels
- **Content**: Main app interface
- **Style**: Clean app screenshot

### **3. App Icon (traxicon.png)**
- **Size**: 512x512 pixels
- **Status**: ✅ Already exists in your project

---

## **APK Upload Process**

### **1. Build Release APK**
```bash
cd trax_radio
flutter build apk --release
```

### **2. Copy APK to Website**
```bash
# Copy APK to website releases folder
cp build/app/outputs/flutter-apk/app-release.apk website/releases/trax-radio-uk-v1.0.0.apk
```

### **3. Update Download Links**
- Update `index.html` with correct APK filename
- Update version numbers as needed

---

## **Customization**

### **Update Contact Information**
1. **Edit `index.html`**
   - Replace `[Your Email]` with your email
   - Replace `[Your Website]` with your website
   - Replace `[Your Business Address]` with your address

2. **Edit `privacy-policy.html`**
   - Update contact information
   - Add your business details

### **Update App Information**
1. **Version numbers** in download section
2. **App size** information
3. **Release notes** for new versions
4. **Feature descriptions** as needed

---

## **Testing Checklist**

### **Before Going Live**
- [ ] All images are uploaded and display correctly
- [ ] APK download link works
- [ ] Privacy policy page loads
- [ ] Mobile responsive design works
- [ ] Contact information is updated
- [ ] All links work properly

### **Mobile Testing**
- [ ] Test on Android phone
- [ ] Test on iPhone (for website viewing)
- [ ] Test download functionality
- [ ] Test responsive design

---

## **SEO Optimization**

### **Meta Tags (Already Included)**
- Title tag
- Description tag
- Viewport tag
- Favicon

### **Additional SEO**
- Add Google Analytics (optional)
- Submit to Google Search Console
- Add structured data (optional)

---

## **Analytics (Optional)**

### **Google Analytics**
1. **Create Google Analytics account**
2. **Get tracking code**
3. **Add to `index.html` before closing `</head>` tag**

### **Basic Analytics Code**
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

---

## **Domain Setup (Optional)**

### **Custom Domain**
1. **Buy domain** (GoDaddy, Namecheap, etc.)
2. **Point DNS** to your hosting provider
3. **Update website** with custom domain
4. **Add SSL certificate** (usually automatic)

### **Popular Domain Options**
- `traxradiouk.com`
- `traxradio.app`
- `traxradio.uk`
- `traxradio.download`

---

## **Maintenance**

### **Regular Updates**
- Update APK files for new versions
- Update version numbers
- Update release notes
- Test download functionality

### **Backup**
- Keep local copies of all files
- Use Git for version control
- Regular backups of hosting account

---

## **Support**

### **If You Need Help**
- Check hosting provider documentation
- GitHub Pages: [GitHub Docs](https://docs.github.com/en/pages)
- Netlify: [Netlify Docs](https://docs.netlify.com)
- Vercel: [Vercel Docs](https://vercel.com/docs)

---

**Your website is ready to go live!** 🚀

**Next steps:**
1. Choose hosting option (GitHub Pages recommended)
2. Upload files
3. Test everything
4. Share your website URL!

