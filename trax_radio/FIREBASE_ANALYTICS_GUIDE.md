# 📊 Firebase Analytics Setup & Optimization Guide

## 🚀 Step-by-Step Setup

### **Step 1: Firebase Console Setup**
1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: Trax Radio UK
3. **Navigate to Analytics**: Click "Analytics" in left sidebar
4. **Enable Analytics**: If not already enabled, click "Enable"

### **Step 2: App Configuration** ✅ COMPLETED
- **Firebase Core**: Initialized in main.dart
- **Firebase Analytics**: Added to dependencies
- **Event Tracking**: Implemented for key actions

### **Step 3: Custom Events Implemented**

#### **🎵 Audio Events**
```dart
// Play Event
FirebaseAnalytics.instance.logEvent(
  name: 'radio_play',
  parameters: {
    'stream_url': streamUrl,
    'device_type': 'mobile',
  },
);

// Pause Event
FirebaseAnalytics.instance.logEvent(
  name: 'radio_pause',
  parameters: {
    'session_duration': DateTime.now().millisecondsSinceEpoch,
  },
);

// Error Event
FirebaseAnalytics.instance.logEvent(
  name: 'radio_error',
  parameters: {
    'error_message': e.toString(),
    'stream_url': streamUrl,
  },
);
```

#### **📱 App Lifecycle Events**
```dart
// App Open Event
FirebaseAnalytics.instance.logEvent(
  name: 'app_open',
  parameters: {
    'app_version': '1.0.0',
    'device_type': 'mobile',
  },
);
```

## 📈 Analytics Dashboard Setup

### **Step 4: Firebase Console Configuration**

#### **4.1 Create Custom Events**
1. **Go to Analytics** → **Events**
2. **Click "Create Event"**
3. **Add these custom events**:
   - `radio_play`
   - `radio_pause`
   - `radio_error`
   - `app_open`

#### **4.2 Set up Conversions**
1. **Go to Analytics** → **Conversions**
2. **Mark important events**:
   - `radio_play` (Primary conversion)
   - `app_open` (Secondary conversion)

#### **4.3 Create Audiences**
1. **Go to Analytics** → **Audiences**
2. **Create these audiences**:
   - **Active Listeners**: Users who play radio > 5 minutes
   - **Error Users**: Users who encounter errors
   - **New Users**: First-time app opens

## 📊 Key Metrics to Track

### **🎯 User Engagement**
- **Daily Active Users (DAU)**
- **Session Duration**
- **Play Sessions per Day**
- **Retention Rate (Day 1, Day 7, Day 30)**

### **🎵 Audio Performance**
- **Play Success Rate**
- **Error Rate by Device**
- **Stream Quality Issues**
- **Session Duration Distribution**

### **📱 App Performance**
- **App Launch Time**
- **Crash Rate**
- **Device Compatibility**
- **Android Version Distribution**

## 🔧 Advanced Analytics Setup

### **Step 5: Custom Parameters**

#### **User Properties**
```dart
// Set user properties
FirebaseAnalytics.instance.setUserProperty(
  name: 'user_type',
  value: 'dj', // or 'listener'
);

FirebaseAnalytics.instance.setUserProperty(
  name: 'device_model',
  value: 'Samsung Galaxy S25',
);
```

#### **Enhanced Event Tracking**
```dart
// Track visualizer usage
FirebaseAnalytics.instance.logEvent(
  name: 'visualizer_interaction',
  parameters: {
    'interaction_type': 'tap',
    'visualizer_active': 'true',
  },
);

// Track DJ info views
FirebaseAnalytics.instance.logEvent(
  name: 'dj_info_view',
  parameters: {
    'dj_name': currentDJ,
    'view_duration': 5000, // milliseconds
  },
);
```

### **Step 6: Funnel Analysis**

#### **User Journey Tracking**
1. **App Open** → `app_open`
2. **Play Button Tap** → `radio_play`
3. **Successful Stream** → `stream_success`
4. **Session End** → `radio_pause`

## 📋 Analytics Dashboard Views

### **Step 7: Create Custom Reports**

#### **7.1 User Engagement Dashboard**
- **Metrics**: DAU, Session Duration, Retention
- **Filters**: Device Type, Android Version
- **Time Range**: Last 30 days

#### **7.2 Audio Performance Dashboard**
- **Metrics**: Play Success Rate, Error Rate
- **Filters**: Device Model, Network Type
- **Alerts**: Error Rate > 5%

#### **7.3 DJ Usage Dashboard**
- **Metrics**: DJ Info Views, Session Duration
- **Filters**: User Type (DJ vs Listener)
- **Segments**: Active DJs

## 🎯 Optimization Strategies

### **Step 8: Data-Driven Improvements**

#### **8.1 Performance Optimization**
- **Monitor crash rates** by device model
- **Track app launch times** across devices
- **Identify slow-loading components**

#### **8.2 User Experience Optimization**
- **Analyze session patterns** to improve UI
- **Track feature usage** to prioritize development
- **Monitor error patterns** to fix issues

#### **8.3 Content Optimization**
- **Track DJ popularity** based on session duration
- **Monitor peak listening times**
- **Analyze user retention** patterns

## 📊 Reporting Schedule

### **Daily Reports**
- **Active Users**
- **Error Rate**
- **Play Success Rate**

### **Weekly Reports**
- **User Retention**
- **Feature Usage**
- **Device Performance**

### **Monthly Reports**
- **User Growth**
- **Engagement Trends**
- **Performance Improvements**

## 🔔 Alert Setup

### **Step 9: Configure Alerts**
1. **Go to Analytics** → **Alerts**
2. **Create these alerts**:
   - **High Error Rate**: > 5% error rate
   - **Low Engagement**: < 50% daily active users
   - **Performance Issues**: > 10 second app launch time

## 📈 Success Metrics

### **Target KPIs**
- **Daily Active Users**: > 100
- **Session Duration**: > 10 minutes average
- **Error Rate**: < 2%
- **Retention Rate**: > 60% (Day 7)

### **Growth Metrics**
- **Monthly Active Users**: Track growth
- **Feature Adoption**: Monitor new feature usage
- **User Satisfaction**: Track positive feedback

---

## 🚀 Next Steps

### **Immediate Actions**
1. **Deploy current build** with analytics
2. **Monitor initial data** for 1 week
3. **Set up alerts** for critical metrics
4. **Create custom reports** for stakeholders

### **Ongoing Optimization**
1. **Weekly review** of analytics data
2. **Monthly optimization** based on insights
3. **Quarterly strategy** adjustments

---

**Status**: Analytics Implementation Complete ✅  
**Next Review**: After 1 week of data collection  
**Optimization Phase**: Ready to begin 