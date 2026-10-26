import 'package:flutter/material.dart';
import '../../features/branch_manager/auth/screens/manager_login_screen.dart';
import '../../features/branch_manager/bookings/screens/manager_booking_details_screen.dart';
import '../../features/branch_manager/bookings/screens/manager_bookings_screen.dart';
import '../../features/branch_manager/dashboard/screens/branch_manager_dashboard_screen.dart';
import '../../features/branch_manager/navigation/manager_navigation_shell.dart';
import '../../features/branch_manager/notifications/screens/manager_notifications_screen.dart';
import '../../features/branch_manager/profile/screens/manager_profile_screen.dart';
import '../../features/branch_manager/services/screens/manager_services_screen.dart';
import '../../features/branch_manager/staff/screens/manager_staff_screen.dart';
import '../../features/customer/auth/screens/customer_login_screen.dart';
import '../../features/customer/auth/screens/customer_otp_screen.dart';
import '../../features/customer/navigation/customer_navigation_shell.dart';
import '../../features/customer/preference/screens/customer_preference_screen.dart';
import '../../features/customer/profile/screens/customer_profile_setup_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/partner/auth/screens/partner_login_screen.dart';
import '../../features/partner/auth/screens/partner_register_screen.dart';
import '../../features/partner/bookings/screens/booking_details_screen.dart';
import '../../features/partner/bookings/screens/partner_bookings_screen.dart';
import '../../features/partner/dashboard/screens/partner_dashboard_screen.dart';
import '../../features/partner/earnings/screens/earnings_screen.dart';
import '../../features/partner/home_service/screens/home_service_settings_screen.dart';
import '../../features/partner/navigation/partner_navigation_shell.dart';
import '../../features/partner/notifications/screens/partner_notifications_screen.dart';
import '../../features/partner/onboarding/screens/create_branch_manager_screen.dart';
import '../../features/partner/onboarding/screens/create_salon_screen.dart';
import '../../features/partner/profile/screens/partner_profile_screen.dart';
import '../../features/partner/salon/screens/branches_screen.dart';
import '../../features/partner/salon/screens/edit_salon_screen.dart';
import '../../features/partner/salon/screens/salon_details_screen.dart';
import '../../features/partner/services/screens/add_service_screen.dart';
import '../../features/partner/services/screens/services_screen.dart';
import '../../features/partner/staff/screens/staff_screen.dart';
import '../../features/partner/verification/screens/document_verification_screen.dart';
import '../../features/partner/verification/screens/verification_status_screen.dart';
import '../../features/role_selection/screens/choose_role_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String chooseRole = '/choose-role';
  static const String customerPreference = '/customer-preference';
  static const String customerLogin = '/customer-login';
  static const String customerOtp = '/customer-otp';
  static const String customerProfileSetup = '/customer-profile-setup';
  static const String customerHome = '/customer-home';
  static const String partnerLogin = '/partner-login';
  static const String managerLogin = '/manager-login';

  // Branch Manager Flow Routes
  static const String managerMain = '/manager-main';
  static const String managerDashboard = '/manager-dashboard';
  static const String managerBookings = '/manager-bookings';
  static const String managerBookingDetails = '/manager-booking-details';
  static const String managerServices = '/manager-services';
  static const String managerStaff = '/manager-staff';
  static const String managerNotifications = '/manager-notifications';
  static const String managerProfile = '/manager-profile';

  // Partner Flow Routes
  static const String partnerRegister = '/partner-register';
  static const String partnerVerification = '/partner-verification';
  static const String partnerVerificationStatus = '/partner-verification-status';
  static const String partnerCreateSalon = '/partner-create-salon';
  static const String partnerCreateManager = '/partner-create-manager';
  static const String partnerMain = '/partner-main';
  static const String partnerDashboard = '/partner-dashboard';
  static const String partnerSalonDetails = '/partner-salon-details';
  static const String partnerEditSalon = '/partner-edit-salon';
  static const String partnerBranches = '/partner-branches';
  static const String partnerServices = '/partner-services';
  static const String partnerAddService = '/partner-add-service';
  static const String partnerHomeService = '/partner-home-service';
  static const String partnerBookings = '/partner-bookings';
  static const String partnerBookingDetails = '/partner-booking-details';
  static const String partnerStaff = '/partner-staff';
  static const String partnerEarnings = '/partner-earnings';
  static const String partnerNotifications = '/partner-notifications';
  static const String partnerProfile = '/partner-profile';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        chooseRole: (context) => const ChooseRoleScreen(),
        customerPreference: (context) => const CustomerPreferenceScreen(),
        customerLogin: (context) => const CustomerLoginScreen(),
        customerOtp: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as CustomerOtpScreenArgs;
          return CustomerOtpScreen(args: args);
        },
        customerProfileSetup: (context) => const CustomerProfileSetupScreen(),
        customerHome: (context) => const CustomerNavigationShell(),
        partnerLogin: (context) => const PartnerLoginScreen(),
        managerLogin: (context) => const ManagerLoginScreen(),

        // Branch Manager Routes
        managerMain: (context) => const ManagerNavigationShell(),
        managerDashboard: (context) => const BranchManagerDashboardScreen(),
        managerBookings: (context) => const ManagerBookingsScreen(),
        managerBookingDetails: (context) => const ManagerBookingDetailsScreen(),
        managerServices: (context) => const ManagerServicesScreen(),
        managerStaff: (context) => const ManagerStaffScreen(),
        managerNotifications: (context) => const ManagerNotificationsScreen(),
        managerProfile: (context) => const ManagerProfileScreen(),

        // Partner Panel Routes
        partnerRegister: (context) => const PartnerRegisterScreen(),
        partnerVerification: (context) => const DocumentVerificationScreen(),
        partnerVerificationStatus: (context) => const VerificationStatusScreen(),
        partnerCreateSalon: (context) => const CreateSalonScreen(),
        partnerCreateManager: (context) => const CreateBranchManagerScreen(),
        partnerMain: (context) => const PartnerNavigationShell(),
        partnerDashboard: (context) => const PartnerDashboardScreen(),
        partnerSalonDetails: (context) => const SalonDetailsScreen(),
        partnerEditSalon: (context) => const EditSalonScreen(),
        partnerBranches: (context) => const BranchesScreen(),
        partnerServices: (context) => const ServicesScreen(),
        partnerAddService: (context) => const AddServiceScreen(),
        partnerHomeService: (context) => const HomeServiceSettingsScreen(),
        partnerBookings: (context) => const PartnerBookingsScreen(),
        partnerBookingDetails: (context) => const BookingDetailsScreen(),
        partnerStaff: (context) => const StaffScreen(),
        partnerEarnings: (context) => const EarningsScreen(),
        partnerNotifications: (context) => const PartnerNotificationsScreen(),
        partnerProfile: (context) => const PartnerProfileScreen(),
      };
}
