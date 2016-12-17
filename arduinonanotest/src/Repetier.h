/*
    This file is part of Repetier-Firmware.

    Repetier-Firmware is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Repetier-Firmware is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Repetier-Firmware.  If not, see <http://www.gnu.org/licenses/>.

    This firmware is a nearly complete rewrite of the sprinter firmware
    by kliment (https://github.com/kliment/Sprinter)
    which based on Tonokip RepRap firmware rewrite based off of Hydra-mmm firmware.
*/

#ifndef _REPETIER_H
#define _REPETIER_H

#ifdef Arduino_h
#error "Arduino already included"
#endif

#include <math.h>
#include <stdint.h>
#define REPETIER_VERSION "0.92.9"

// ##########################################################################################
// ##                                  Debug configuration                                 ##
// ##########################################################################################
// These are run time switchable debug flags
enum debugFlags {DEB_ECHO = 0x1, DEB_INFO = 0x2, DEB_ERROR = 0x4,DEB_DRYRUN = 0x8,
                 DEB_COMMUNICATION = 0x10, DEB_NOMOVES = 0x20, DEB_DEBUG = 0x40
                };

/** Uncomment, to see detailed data for every move. Only for debugging purposes! */
//#define DEBUG_QUEUE_MOVE
/** write infos about path planner changes */
//#define DEBUG_PLANNER
/** Allows M111 to set bit 5 (16) which disables all commands except M111. This can be used
to test your data throughput or search for communication problems. */
#define INCLUDE_DEBUG_COMMUNICATION 1
/** Allows M111 so set bit 6 (32) which disables moves, at the first tried step. In combination
with a dry run, you can test the speed of path computations, which are still performed. */
#define INCLUDE_DEBUG_NO_MOVE 1
/** Writes the free RAM to output, if it is less then at the last test. Should always return
values >500 for safety, since it doesn't catch every function call. Nice to tweak cache
usage or for searching for memory induced errors. Switch it off for production, it costs execution time. */
//#define DEBUG_FREE_MEMORY
//#define DEBUG_ADVANCE
/** If enabled, writes the created generic table to serial port at startup. */
//#define DEBUG_GENERIC
/** If enabled, steps to move and moved steps are compared. */
//#define DEBUG_STEPCOUNT
/** This enables code to make M666 drop an ok, so you get problems with communication. It is to test host robustness. */
//#define DEBUG_COM_ERRORS
/** Adds a menu point in quick settings to write debug informations to the host in case of hangs where the ui still works. */
//#define DEBUG_PRINT
//#define DEBUG_DELTA_OVERFLOW
//#define DEBUG_DELTA_REALPOS
//#define DEBUG_SPLIT
//#define DEBUG_JAM
// Find the longest segment length during a print
//#define DEBUG_SEGMENT_LENGTH
// Find the maximum real jerk during a print
//#define DEBUG_REAL_JERK
// Debug reason for not mounting a sd card
//#define DEBUG_SD_ERROR
// Uncomment the following line to enable debugging. You can better control debugging below the following line
//#define DEBUG

#define CARTESIAN 0
#define XY_GANTRY 1
#define YX_GANTRY 2
#define DELTA 3
#define TUGA 4
#define BIPOD 5
#define XZ_GANTRY 8
#define ZX_GANTRY 9
#define GANTRY_FAKE 10

#define WIZARD_STACK_SIZE 8
#define IGNORE_COORDINATE 999999

#define X_AXIS 0
#define Y_AXIS 1
#define Z_AXIS 2
#define E_AXIS 3
#define VIRTUAL_AXIS 4
// How big an array to hold X_AXIS..<MAX_AXIS>
#define Z_AXIS_ARRAY 3
#define E_AXIS_ARRAY 4
#define VIRTUAL_AXIS_ARRAY 5


#define A_TOWER 0
#define B_TOWER 1
#define C_TOWER 2
#define TOWER_ARRAY 3
#define E_TOWER_ARRAY 4

#define ANALOG_REF_AREF 0
#define ANALOG_REF_AVCC _BV(REFS0)
#define ANALOG_REF_INT_1_1 _BV(REFS1)
#define ANALOG_REF_INT_2_56 _BV(REFS0) | _BV(REFS1)
#define ANALOG_REF ANALOG_REF_AVCC

#define HOME_ORDER_XYZ 1
#define HOME_ORDER_XZY 2
#define HOME_ORDER_YXZ 3
#define HOME_ORDER_YZX 4
#define HOME_ORDER_ZXY 5
#define HOME_ORDER_ZYX 6
#define HOME_ORDER_ZXYTZ 7 // Needs hot hotend for correct homing
#define HOME_ORDER_XYTZ 8 // Needs hot hotend for correct homing

//direction flags
#define X_DIRPOS 1
#define Y_DIRPOS 2
#define Z_DIRPOS 4
#define E_DIRPOS 8
#define XYZ_DIRPOS 7
//step flags
#define XSTEP 16
#define YSTEP 32
#define ZSTEP 64
#define ESTEP 128
//combo's
#define XYZ_STEP 112
#define XY_STEP 48
#define XYZE_STEP 240
#define E_STEP_DIRPOS 136
#define Y_STEP_DIRPOS 34
#define X_STEP_DIRPOS 17
#define Z_STEP_DIRPOS 68

#define PRINTER_MODE_FFF 0
#define PRINTER_MODE_LASER 1
#define PRINTER_MODE_CNC 2

#define ILLEGAL_Z_PROBE -888

// we can not prevent this as some configurations need a parameter and others not
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-variable"

#include "Configuration.h"

#ifndef DUAL_X_AXIS
#define DUAL_X_AXIS 0
#endif


#define XY_GANTRY 1
#define YX_GANTRY 2
#define DELTA 3
#define TUGA 4
#define BIPOD 5
#define XZ_GANTRY 8
#define ZX_GANTRY 9
#if defined(FAST_COREXYZ) && !(DRIVE_SYSTEM==XY_GANTRY || DRIVE_SYSTEM==YX_GANTRY || DRIVE_SYSTEM==XZ_GANTRY || DRIVE_SYSTEM==ZX_GANTRY || DRIVE_SYSTEM==GANTRY_FAKE)
#undef FAST_COREXYZ
#endif
#ifdef FAST_COREXYZ
#if DELTA_SEGMENTS_PER_SECOND_PRINT < 30
#undef DELTA_SEGMENTS_PER_SECOND_PRINT
#define DELTA_SEGMENTS_PER_SECOND_PRINT 30 // core is linear, no subsegments needed
#endif
#if DELTA_SEGMENTS_PER_SECOND_MOVE < 30
#undef DELTA_SEGMENTS_PER_SECOND_MOVE
#define DELTA_SEGMENTS_PER_SECOND_MOVE 30
#endif
#endif

inline void memcopy2(void *dest,void *source) {
    *((int16_t*)dest) = *((int16_t*)source);
}
inline void memcopy4(void *dest,void *source) {
    *((int32_t*)dest) = *((int32_t*)source);
}

#ifndef JSON_OUTPUT
#define JSON_OUTPUT 0
#endif


#ifndef ZHOME_X_POS
#define ZHOME_X_POS IGNORE_COORDINATE
#endif
#ifndef ZHOME_Y_POS
#define ZHOME_Y_POS IGNORE_COORDINATE
#endif

// MS1 MS2 Stepper Driver Micro stepping mode table
#define MICROSTEP1 LOW,LOW
#define MICROSTEP2 HIGH,LOW
#define MICROSTEP4 LOW,HIGH
#define MICROSTEP8 HIGH,HIGH
#if (MOTHERBOARD == 501)
#define MICROSTEP16 LOW,LOW
#else
#define MICROSTEP16 HIGH,HIGH
#endif
#define MICROSTEP32 HIGH,HIGH

#define GCODE_BUFFER_SIZE 1


#ifndef MINMAX_HARDWARE_ENDSTOP_Z2
#define MINMAX_HARDWARE_ENDSTOP_Z2 0
#define Z2_MINMAX_PIN -1
#endif

#define SPEED_MIN_MILLIS 400
#define SPEED_MAX_MILLIS 60
#define SPEED_MAGNIFICATION 100.0f


#define NONLINEAR_SYSTEM 0


#define GANTRY ( DRIVE_SYSTEM==XY_GANTRY || DRIVE_SYSTEM==YX_GANTRY || DRIVE_SYSTEM==XZ_GANTRY || DRIVE_SYSTEM==ZX_GANTRY || DRIVE_SYSTEM==GANTRY_FAKE)

//Step to split a circle in small Lines
#ifndef MM_PER_ARC_SEGMENT
#define MM_PER_ARC_SEGMENT 1
#define MM_PER_ARC_SEGMENT_BIG 3
#else
#define MM_PER_ARC_SEGMENT_BIG MM_PER_ARC_SEGMENT
#endif
//After this count of steps a new SIN / COS calculation is started to correct the circle interpolation
#define N_ARC_CORRECTION 25


#define SHARED_COOLER 0

#ifndef START_STEP_WITH_HIGH
#define START_STEP_WITH_HIGH 1
#endif


#ifndef DEBUG_FREE_MEMORY
#define DEBUG_MEMORY
#else
#define DEBUG_MEMORY Commands::checkFreeMemory();
#endif


#include "HAL.h"
//#include "gcode.h"

//#include "ui.h"
#include "Communication.h"


#define uint uint16_t
#define uint8 uint8_t
#define int8 int8_t
#define uint32 uint32_t
#define int32 int32_t


#undef min
#undef max

class RMath
{
public:
    static inline float min(float a,float b)
    {
        if(a < b) return a;
        return b;
    }
    static inline float max(float a,float b)
    {
        if(a < b) return b;
        return a;
    }
    static inline int32_t min(int32_t a,int32_t b)
    {
        if(a < b) return a;
        return b;
    }
    static inline int32_t min(int32_t a,int32_t b, int32_t c)
    {
        if(a < b) return a < c ? a : c;
        return b<c ? b : c;
    }
    static inline float min(float a,float b, float c)
    {
        if(a < b) return a < c ? a : c;
        return b < c ? b : c;
    }
    static inline int32_t max(int32_t a,int32_t b)
    {
        if(a < b) return b;
        return a;
    }
    static inline int min(int a,int b)
    {
        if(a < b) return a;
        return b;
    }
    static inline uint16_t min(uint16_t a,uint16_t b)
    {
        if(a < b) return a;
        return b;
    }
    static inline int16_t max(int16_t a,int16_t b)
    {
        if(a < b) return b;
        return a;
    }
    static inline uint16_t max(uint16_t a,uint16_t b)
    {
        if(a < b) return b;
        return a;
    }
    static inline unsigned long absLong(long a)
    {
        return a >= 0 ? a : -a;
    }
    static inline int32_t sqr(int32_t a)
    {
        return a*a;
    }
    static inline uint32_t sqr(uint32_t a)
    {
        return a*a;
    }
#ifdef SUPPORT_64_BIT_MATH
    static inline int64_t sqr(int64_t a)
    {
        return a*a;
    }
    static inline uint64_t sqr(uint64_t a)
    {
        return a*a;
    }
#endif

    static inline float sqr(float a)
    {
        return a*a;
    }
};

class RVector3
{
public:
    float x, y, z;
    RVector3(float _x = 0,float _y = 0,float _z = 0):x(_x),y(_y),z(_z) {};
    RVector3(const RVector3 &a):x(a.x),y(a.y),z(a.z) {};


/*    const float &operator[](std::size_t idx) const
    {
        if(idx == 0) return x;
        if(idx == 1) return y;
        return z;
    };

    float &operator[](std::size_t idx)
    {
        switch(idx) {
        case 0: return x;
        case 1: return y;
        case 2: return z;
        }
        return 0;
    };*/

    inline bool operator==(const RVector3 &rhs)
    {
        return x==rhs.x && y==rhs.y && z==rhs.z;
    }
    inline bool operator!=(const RVector3 &rhs)
    {
        return !(*this==rhs);
    }
    inline RVector3& operator=(const RVector3 &rhs)
    {
        if(this!=&rhs)
        {
            x = rhs.x;
            y = rhs.y;
            z = rhs.z;
        }
        return *this;
    }

    inline RVector3& operator+=(const RVector3 &rhs)
    {
        x += rhs.x;
        y += rhs.y;
        z += rhs.z;
        return *this;
    }

    inline RVector3& operator-=(const RVector3 &rhs)
    {
        x -= rhs.x;
        y -= rhs.y;
        z -= rhs.z;
        return *this;
    }
    inline RVector3 operator-() const
    {
        return RVector3(-x,-y,-z);
    }

    inline float length() const
    {
        return sqrt(x * x + y * y + z * z);
    }

    inline float lengthSquared() const
    {
        return (x*x+y*y+z*z);
    }

    inline RVector3 cross(const RVector3 &b) const
    {
        return RVector3(y*b.z-z*b.y,z*b.x-x*b.z,x*b.y-y*b.x);
    }
    inline float scalar(const RVector3 &b) const
    {
        return (x*b.x+y*b.y+z*b.z);
    }
    inline RVector3 scale(float factor) const
    {
        return RVector3(x*factor,y*factor,z*factor);
    }
    inline void scaleIntern(float factor)
    {
        x*=factor;
        y*=factor;
        z*=factor;
    }
    inline void setMinimum(const RVector3 &b)
    {
        x = RMath::min(x,b.x);
        y = RMath::min(y,b.y);
        z = RMath::min(z,b.z);
    }
    inline void setMaximum(const RVector3 &b)
    {
        x = RMath::max(x,b.x);
        y = RMath::max(y,b.y);
        z = RMath::max(z,b.z);
    }
    inline float distance(const RVector3 &b) const
    {
        float dx = b.x-x,dy = b.y-y, dz = b.z-z;
        return (sqrt(dx*dx+dy*dy+dz*dz));
    }
    inline float angle(RVector3 &direction)
    {
        return static_cast<float>(acos(scalar(direction)/(length()*direction.length())));
    }

    inline RVector3 normalize() const
    {
        float len = length();
        if(len != 0) len = static_cast<float>(1.0/len);
        return RVector3(x*len,y*len,z*len);
    }

    inline RVector3 interpolatePosition(const RVector3 &b, float pos) const
    {
        float pos2 = 1.0f - pos;
        return RVector3(x * pos2 + b.x * pos, y * pos2 + b.y * pos, z * pos2 + b.z * pos);
    }

    inline RVector3 interpolateDirection(const RVector3 &b,float pos) const
    {
        //float pos2 = 1.0f - pos;

        float dot = scalar(b);
        if (dot > 0.9995 || dot < -0.9995)
            return interpolatePosition(b,pos); // cases cause trouble, use linear interpolation here

        float theta = acos(dot) * pos; // interpolated position
        float st = sin(theta);
        RVector3 t(b);
        t -= scale(dot);
        float lengthSq = t.lengthSquared();
        float dl = st * ((lengthSq < 0.0001f) ? 1.0f : 1.0f / sqrt(lengthSq));
        t.scaleIntern(dl);
        t += scale(cos(theta));
        return t.normalize();
    }
};
    inline RVector3 operator+(RVector3 lhs, const RVector3& rhs) // first arg by value, second by const ref
    {
        lhs.x += rhs.x;
        lhs.y += rhs.y;
        lhs.z += rhs.z;
        return lhs;
    }

    inline RVector3 operator-(RVector3 lhs, const RVector3& rhs) // first arg by value, second by const ref
    {
        lhs.x -= rhs.x;
        lhs.y -= rhs.y;
        lhs.z -= rhs.z;
        return lhs;
    }

    inline RVector3 operator*(const RVector3 &lhs,float rhs) {
        return lhs.scale(rhs);
    }

    inline RVector3 operator*(float lhs,const RVector3 &rhs) {
        return rhs.scale(lhs);
    }
extern const uint8 osAnalogInputChannels[] PROGMEM;
//extern uint8 osAnalogInputCounter[ANALOG_INPUTS];
//extern uint osAnalogInputBuildup[ANALOG_INPUTS];
//extern uint8 osAnalogInputPos; // Current sampling position
#if ANALOG_INPUTS > 0
extern volatile uint osAnalogInputValues[ANALOG_INPUTS];
#endif

#define NUM_PWM 2

extern uint8_t pwm_pos[NUM_PWM]; // 0-NUM_EXTRUDER = Heater 0-NUM_EXTRUDER of extruder, NUM_EXTRUDER = Heated bed, NUM_EXTRUDER+1 Board fan, NUM_EXTRUDER+2 = Fan

#if USE_ADVANCE
#if ENABLE_QUADRATIC_ADVANCE
extern int maxadv;
#endif
extern int maxadv2;
extern float maxadvspeed;
#endif


//#include "Extruder.h"

void manage_inactivity(uint8_t debug);

extern void finishNextSegment();
extern void linear_move(long steps_remaining[]);


extern millis_t previousMillisCmd;
extern millis_t maxInactiveTime;
extern millis_t stepperInactiveTime;

extern void setupTimerInterrupt();
extern void motorCurrentControlInit();
extern void microstepInit();

#include "Eggbot.h"
//#include "motion.h"
extern long baudrate;

#include "HAL.h"


extern unsigned int counterPeriodical;
extern volatile uint8_t executePeriodical;
extern uint8_t counter500ms;
extern void writeMonitor();


extern volatile int waitRelax; // Delay filament relax at the end of print, could be a simple timeout
// PHAIAX FIXME
//extern void updateStepsParameter(PrintLine *p/*,uint8_t caller*/);

#ifdef DEBUG_PRINT
extern int debugWaitLoop;
#endif


#define STR(s) #s
#define XSTR(s) STR(s)
//#include "Commands.h"
//#include "Eeprom.h"

#if CPU_ARCH == ARCH_AVR
#define DELAY1MICROSECOND        __asm__("nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t")
#define DELAY2MICROSECOND        __asm__("nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\tnop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t")
#else
#define DELAY1MICROSECOND     HAL::delayMicroseconds(1);
#define DELAY2MICROSECOND     HAL::delayMicroseconds(2);
#endif

#ifdef FAST_INTEGER_SQRT
#define SQRT(x) ( HAL::integerSqrt(x) )
#else
#define SQRT(x) sqrt(x)
#endif

//#include "Drivers.h"

//#include "Events.h"
#if defined(CUSTOM_EVENTS)
//#include "CustomEvents.h"
#endif

#endif
